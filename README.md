## Input Range in Elm 

Re-createing `input[type=range]` in Elm, sort of study on how to handle mouse events and make it resuable in Elm Architecture.


## Requirement

* on mouse down, immediate set value to that position
* on mouse move + mouse down, set the value to the cursor position.
* on mouse up, set the value to the cursor position
* when mouse move outside of the element, still calculating the position.
* when mouse move beyond the max/min, bound the position within element.
* allow multiple instance

## BoilerPlate Code to connect to component

```elm
type alias Model =
    { range1 : RangeSlider.Model }


type Msg
    = RangeSlider1Msg RangeSlider.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RangeSlider1Msg rangeSliderMsg ->
            ({ model | range1 = RangeSlider.update rangeSliderMsg model.range1 }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.range1.dragging /= Nothing then
        RangeSlider.subscriptions model.range1
            |> Sub.map RangeSlider1Msg


view : Model -> Html Msg
view model =
    div
        []
        [ App.map RangeSlider1Msg <| RangeSlider.view model.range1
        ]
```
