module Main where

import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Graphics.Input exposing (..)
import Graphics.Input.Field exposing (..)
import Signal
import Text

import WebSocket

main : Signal Element
main = Signal.map (view actions.address) model

model : Signal Model
model = Signal.foldp update init signals

socket = WebSocket.socket

signals = Signal.mergeMany [ actions.signal
                           , Signal.map DecodeMessage <| WebSocket.onmessage socket
                           , Signal.map DecodeError <| WebSocket.onerror socket
                           ]

actions : Signal.Mailbox Action
actions = Signal.mailbox NoOp

-- model
type alias Model = { socketOpen: Bool
                   , url: Content
                   , sendMessage: Content
                   , recvMessage: String
                   }

init = { socketOpen = False
       , url = initContent "ws://echo.websocket.org"
       , sendMessage = emptyContent
       , recvMessage = ""
       }

initContent s = { string=s, selection=Selection 0 0 Forward }
emptyContent = initContent ""

-- actions
type Action = NoOp
            | UpdateUrl Content
            | UpdateSendMessage Content
            | OpenCloseSocket
            | Send
            | DecodeMessage String
            | DecodeError String

update : Action -> Model -> Model
update action model =
  case action of
    NoOp -> model
    UpdateUrl c -> { model | url=c }
    UpdateSendMessage c -> { model | sendMessage=c }
    OpenCloseSocket -> case model.socketOpen of
      True  -> let _ = WebSocket.close WebSocket.CLOSE_NORMAL socket
               in { model | socketOpen = False }
      False -> let _ = WebSocket.connect model.url.string socket
               in { model | socketOpen = True }
    Send -> case model.socketOpen of
      True  -> let _ = WebSocket.send model.sendMessage.string socket
               in { model | sendMessage = emptyContent }
      False -> model
    DecodeMessage s -> { model | recvMessage=model.recvMessage++s++"\n" }
    DecodeError s -> { model | socketOpen=False, recvMessage=s }

-- view
view : Signal.Address Action -> Model -> Element
view address model =
  flow down
    [ flow right
      [ field defaultStyle (Signal.message address << UpdateUrl) "Url" model.url
      , button (Signal.message address OpenCloseSocket) (if model.socketOpen then "close" else "open")
      ]
    , flow right
      [ field defaultStyle (Signal.message address << UpdateSendMessage) "Message" model.sendMessage
      , button (Signal.message address Send) "send"
      ]
    , Text.fromString model.recvMessage |> leftAligned
    ]
