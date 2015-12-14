Elm.Native.WebSocket = {};
Elm.Native.WebSocket.make = function(localRuntime) {
  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.WebSocket = localRuntime.Native.WebSocket || {};
  if (localRuntime.Native.WebSocket.values) return localRuntime.Native.WebSocket.values;

	var NS = Elm.Native.Signal.make(localRuntime);
	var Utils = Elm.Native.Utils.make(localRuntime);

  function socket(_) {
    var socket = {
      conn: null,
      onopen: NS.input('WebSocket.onopen', Utils.Tuple0),
      onclose: NS.input('WebSocket.onclose', 1000),
      onerror: NS.input('WebSocket.onerror', ""),
      onmessage: NS.input('WebSocket.onmessage', "")
    }
    return socket
  }

  function connect(uri, socket){
    socket.conn = new WebSocket(uri);
    socket.conn.onopen = function(e) {  localRuntime.notify(socket.onopen.id, Utils.Tuple0); };
    socket.conn.onclose = function(e) { localRuntime.notify(socket.onclose.id, e.code); };
    socket.conn.onmessage = function(e) { localRuntime.notify(socket.onmessage.id, e.data); };
    socket.conn.onerror = function(e) { localRuntime.notify(socket.onerror.id, e.message); };
    return Utils.Tuple0
  }

  function onopen(socket) {
    return socket.onopen
  }

  function onclose(socket) {
    return socket.onclose
  }

  function onmessage(socket) {
    return socket.onmessage
  }

  function onerror(socket) {
    return socket.onerror
  }

  function send(data, socket) {
    socket.conn.send(data)
    return Utils.Tuple0
  }

  function close(code, socket) {
    socket.conn.close(code)
    return Utils.Tuple0
  }

  function status(socket) {
    return socket.conn.readyState
  }

  return localRuntime.Native.WebSocket.values = {  // Export
    socket: socket,
    connect: F2(connect),
    send: F2(send),
    close: F2(close),
    onopen: onopen,
    onclose: onclose,
    onmessage: onmessage,
    onerror: onerror
  };

};
