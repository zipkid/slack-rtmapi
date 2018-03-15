# encoding: utf-8

require 'json'
require 'socket'
require 'websocket/driver'

class Slack
  class RtmApi2
    class Client
      attr_accessor :stop

      def initialize(conf = {})
        @websocket_url = conf.fetch(:websocket_url)
        @url = init_url @websocket_url
        @socket = conf[:socket]
        @driver = conf[:websocket_driver]
        @msg_queue = conf[:msg_queue] || []
        @has_been_init = false
        @stop = false
        @reading = false
        @callbacks = {}
      end

      VALID = [:open, :message, :error, :close]
      def on(type, &block)
        unless VALID.include? type
          raise ArgumentError.new "Client#on accept one of #{VALID.inspect}"
        end

        @callbacks[type] = block
      end

      def send(data)
        data[:id] ||= SecureRandom.random_number 9_999_999
        @msg_queue << data.to_json
      end

      # This init has been delayed because the SSL handshake is a blocking and
      # expensive call
      def init
        return if @has_been_init

        @socket = init_socket(@socket)
        @socket.connect # costly and blocking !

        internalWrapper = (Struct.new :url, :socket do
          def write(*args)
            self.socket.write(*args)
          end
        end).new @url.to_s, @socket

        # this, also, is costly and blocking
        @driver = WebSocket::Driver.client internalWrapper
        @driver.on :open do
          @connected = true
          unless @callbacks[:open].nil?
            @callbacks[:open].call
          end
        end

        @driver.on :error do |event|
          @connected = false
          unless @callbacks[:error].nil?
            @callbacks[:error].call event.message
          end
        end

        @driver.on :message do |event|
          data = JSON.parse event.data
          unless @callbacks[:message].nil?
            @callbacks[:message].call data
          end
        end

        @driver.on :close do |event|
          unless @callbacks[:close].nil?
            @callbacks[:close].call event.code, event.reason
          end
        end

        @driver.start
        @has_been_init = true
      end

      def connected?
        @connected || false
      end

      def read_socket
        @reading = true
        tries = 2
        begin
          data = @socket.read_nonblock 4096
        rescue OpenSSL::SSL::SSLErrorWaitReadable
          tries -= 1
          retry if tries > 0
        end
        @driver.parse data unless data.nil? || data.empty?
        @reading = false
      end

      # All the polling work is done here
      def inner_loop
        return if @stop
        read_socket unless @reading
        @msg_queue.each { |msg| @driver.text msg }
        @msg_queue.clear
        sleep 0.1
      end

      # A dumb simple main loop.
      def main_loop
        init
        loop do
          inner_loop
        end
      end

      private

      def init_url(url)
        url = if url.kind_of? URI then url else URI(url) end
        if url.scheme != 'wss'
          raise ArgumentError.new "config[:websocket_url] should be a valid websocket secure url !"
        end

        url
      end

      def init_socket(socket = nil)
        if socket.kind_of? OpenSSL::SSL::SSLSocket
          socket
        elsif socket.kind_of? TCPSocket
          OpenSSL::SSL::SSLSocket.new socket
        else
          OpenSSL::SSL::SSLSocket.new TCPSocket.new @url.host, 443
        end
      end
    end

  end
end
