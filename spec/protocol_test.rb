require "minitest"
require "minitest/autorun"
require "minitest/spec"
require "socket"
require "json"

describe "Clarke Coin Protocol Spec" do
  attr_reader :port

  before do
    @port = ARGV[0] || 8334
  end

  def symify_json(json_string)
    JSON.parse(json_string).map do |k,v|
      [k.to_sym, v]
    end.to_h
  end

  def transmit_and_recv(data)
    s = TCPSocket.new("localhost", port)
    payload = data.to_json + "\n\n"
    s.write(payload)
    response = s.read
    s.close
    symify_json(response)
  end

  it "echos messages" do
    msg = {message_type: "echo", payload: "pizza"}
    assert_equal msg, transmit_and_recv(msg)
  end

  it "gets peers" do
    msg = {message_type: "get_peers"}
    resp = transmit_and_recv(msg)
    assert_equal [], resp[:payload]
  end

  it "adds a peer" do
  end

  it "pizza" do
    assert port
    assert true
  end
end
