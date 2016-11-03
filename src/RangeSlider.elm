module RangeSlider exposing (..)

import Html exposing (div, text, Html)
import Html.Attributes exposing (style)
import Html.Events exposing (on)
import Json.Decode as Json exposing ((:=))
import Mouse
import DOM


type alias Model =
    { value : Float
    , dragging: Maybe Drag
    , min: Float
    , max: Float
    , step : Float
    }

type alias Drag =
    { left: Float
    , width: Float
    }


type Msg
    = DragStart (Float, Float, Int)
    | DragMove Mouse.Position
    | DragEnd Mouse.Position


update : Msg -> Model -> Model
update msg model =
    case msg of
        DragStart (left, width, x) ->
            let
                drag = {width = width, left = left}
            in
                { model
                    | value = getProgress model drag x
                    , dragging = Just drag
                 }

        DragMove pos ->
            case model.dragging of
                Just drag ->
                    { model | value = getProgress model drag pos.x }
                _ ->
                    model

        DragEnd pos ->
            case model.dragging of
                Just drag ->
                    { model
                        | value = getProgress model drag pos.x
                        , dragging = Nothing
                     }
                _ ->
                    model


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.dragging of
        Just drag ->
            Sub.batch
                [ Mouse.moves DragMove
                , Mouse.ups DragEnd
                ]
        _ ->
            Sub.none


(=>) : a -> b -> (a, b)
(=>) = (,)


view : Model -> Html Msg
view model =
    div
        [ style rangeStyle
        , on "mousedown" <| Json.map DragStart decodeDragLeft
        ]
        [ div
            [ style <|
                trackStyle
                ++ trackProgress
                ++ [ "width" =>
                        (toString ((model.value - model.min ) * 100 / 100) ++ "%")
                   ]
            ]
            []
        , div
            [ style <| trackStyle ++ trackRemain ]
            []
        ]


rangeStyle : List (String, String)
rangeStyle =
    [ "height" => "2rem"
    , "display" => "flex"
    , "flex-direction" => "row"
    , "align-items" => "center"
    , "outline" => "1px dotted #ccc"
    , "background" => "#EEE"
    , "cursor" => "pointer"
    ]


trackStyle: List (String, String)
trackStyle =
    [ "height" => "0.5rem"
      --, "outline" => "1px solid red"
    ]

trackProgress: List (String, String)
trackProgress =
    [ "background-color" => "black"
    ]


trackRemain : List (String, String)
trackRemain =
    [ "flex" => "1"
    , "background-color" => "#ccc"
    ]


decodeDragLeft: Json.Decoder (Float, Float, Int)
decodeDragLeft =
    Json.object2
        (\rect mousePos ->
            ( rect.left
            , rect.width
            , mousePos.x
            )
        )
        ("currentTarget" := DOM.boundingClientRect)
        Mouse.position


getProgress : Model -> Drag -> Int -> Float
getProgress model drag x =
    let
        left =
            (toFloat x - drag.left)
                |> max 0
                |> min drag.width
        progress =
            model.min + (left * model.max) / drag.width
    in
        toFloat (ceiling (progress / model.step)) * model.step
