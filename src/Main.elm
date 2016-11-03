module Main exposing (..)

import Html.App as App
import Html exposing (div, text, Html)
import Html.Attributes exposing (style)
import String
import RangeSlider


type alias Model =
    { range1 : RangeSlider.Model
    , range2 : RangeSlider.Model
    }



type Msg
    = NoOp
    | RangeSlider1Msg RangeSlider.Msg
    | RangeSlider2Msg RangeSlider.Msg


main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ({ range1 =
          { value = 12
          , dragging = Nothing
          , min = 10
          , max = 100
          , step = 0.1
          }
     , range2 =
          { value = 35
          , dragging = Nothing
          , min = 0
          , max = 100
          , step = 5
          }
     }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            (model, Cmd.none)

        RangeSlider1Msg rangeSliderMsg ->
            ({ model | range1 = RangeSlider.update rangeSliderMsg model.range1 }
            , Cmd.none
            )

        RangeSlider2Msg rangeSliderMsg ->
            ({ model | range2 = RangeSlider.update rangeSliderMsg model.range2 }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.range1.dragging /= Nothing then
        RangeSlider.subscriptions model.range1
            |> Sub.map RangeSlider1Msg
    else if model.range2.dragging /= Nothing then
        RangeSlider.subscriptions model.range2
            |> Sub.map RangeSlider2Msg
    else
        Sub.none


(=>) = (,)


view : Model -> Html Msg
view model =
    div
        [ style [ "padding" => "2rem" ] ]
        [ App.map RangeSlider1Msg <| RangeSlider.view model.range1
        , printRangeInfo model.range1
        , App.map RangeSlider2Msg <| RangeSlider.view model.range2
        , printRangeInfo model.range2
        ]


printRangeInfo : RangeSlider.Model -> Html Msg
printRangeInfo range =
    div []
        [ [ "min:" ++ toString range.min
          , "max:" ++ toString range.max
          , "step:" ++ toString range.step
          , "dragging:" ++ (if range.dragging /= Nothing then "true" else "false")
          , "value:" ++ toString range.value
          ]
            |> String.join ", "
            |> text
        ]
