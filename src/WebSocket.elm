module WebSocket
  ( Socket
  , ReadyState ( CONNECTING, OPEN, CLOSING, CLOSED)
  , ExitState ( CLOSE_NORMAL
              , CLOSE_ABNORMAL
              , MissingExtension
              , CLOSE_TOO_LARGE
              , CLOSE_UNSUPPORTED
              , TlsHandshake
              , CLOSE_GOING_AWAY
              , PolicyViolation
              , UnsupportedData
              , ServiceRestart
              , InternalError
              , CLOSE_PROTOCOL_ERROR
              , TryAgainLater
              , CLOSE_NO_STATUS
              , UnknownCode
              )
  , socket
  , connect
  , send
  , status
  , close
  , onopen
  , onclose
  , onmessage
  , onerror
  ) where


{-| Library for Native WebSocket
# types
@docs Socket, ReadyState, ExitState

# methods
@docs socket, connect, send, status, close

# Signals
@docs onopen, onclose, onmessage, onerror

-}

import Native.WebSocket
import Signal exposing (Signal)
import Task exposing (Task,succeed)
import Debug

{-| WebSocket Type -}
type Socket = Socket

{-| Socket status type
based on https://developer.mozilla.org/en-US/docs/Web/API/WebSocket#Ready_state_constants -}
type ReadyState = CONNECTING
                | OPEN
                | CLOSING
                | CLOSED

{-| Socket exit code
based on  https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent -}
type ExitState = CLOSE_NORMAL
               | CLOSE_GOING_AWAY
               | CLOSE_PROTOCOL_ERROR
               | CLOSE_UNSUPPORTED
               | CLOSE_NO_STATUS
               | CLOSE_ABNORMAL
               | UnsupportedData
               | PolicyViolation
               | CLOSE_TOO_LARGE
               | MissingExtension
               | InternalError
               | ServiceRestart
               | TryAgainLater
               | TlsHandshake
               | UnknownCode Int

code2state : Int -> ExitState
code2state code = case code of
  1000 -> CLOSE_NORMAL
  1001 -> CLOSE_GOING_AWAY
  1002 -> CLOSE_PROTOCOL_ERROR
  1003 -> CLOSE_UNSUPPORTED
  1005 -> CLOSE_NO_STATUS
  1006 -> CLOSE_ABNORMAL
  1007 -> UnsupportedData
  1008 -> PolicyViolation
  1009 -> CLOSE_TOO_LARGE
  1010 -> MissingExtension
  1011 -> InternalError
  1012 -> ServiceRestart
  1013 -> TryAgainLater
  1015 -> TlsHandshake
  otherwise -> UnknownCode code

state2code : ExitState -> Int
state2code state = case state of
  CLOSE_NORMAL ->  1000
  CLOSE_GOING_AWAY ->  1001
  CLOSE_PROTOCOL_ERROR ->  1002
  CLOSE_UNSUPPORTED ->  1003
  CLOSE_NO_STATUS ->  1005
  CLOSE_ABNORMAL ->  1006
  UnsupportedData ->  1007
  PolicyViolation ->  1008
  CLOSE_TOO_LARGE ->  1009
  MissingExtension ->  1010
  InternalError ->  1011
  ServiceRestart ->  1012
  TryAgainLater ->  1013
  TlsHandshake ->  1015
  UnknownCode code -> code

{-| socket constructor -}
socket: Socket
socket = Native.WebSocket.socket ()

{-| connect with url -}
connect: String -> Socket -> Task x ()
connect url socket =
  Native.WebSocket.connect url socket |> succeed

{-| send data to socket -}
send: String -> Socket -> Task x ()
send data socket = Native.WebSocket.send data socket |> succeed

{-| close socket with code -}
close: ExitState -> Socket -> Task x ()
close state socket =
  Native.WebSocket.close (state2code state) socket |> succeed

{-| socket status-}
status: Socket -> ReadyState
status socket = case Native.WebSocket.status socket of
  0 -> CONNECTING
  1 -> OPEN
  2 -> CLOSING
  3 -> CLOSED
  otherwise -> Debug.crash "unknown status"

{-| Signal for onopen callback -}
onopen : Socket -> Signal ()
onopen = Native.WebSocket.onopen

{-| Signal for onclose callback -}
onclose : Socket -> Signal ExitState
onclose socket = Signal.map code2state (Native.WebSocket.onclose socket)

{-| Signal for onmessage callback event.data will be return with Signal -}
onmessage : Socket -> Signal String
onmessage = Native.WebSocket.onmessage

{-| Signal for onerror callback event.message will be return with Signal -}
onerror : Socket -> Signal String
onerror = Native.WebSocket.onerror
