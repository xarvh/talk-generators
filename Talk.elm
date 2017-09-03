module Talk exposing (..)

import Slides exposing (..)
import Slides.SlideAnimation as SA
import Slides.FragmentAnimation as FA
import Css exposing (..)
import Css.Elements exposing (..)


font =
    px 20


bgColor =
    rgb 255 255 255


codeBgColor =
    rgb 230 230 230


txtColor =
    hex "60B5CC"


elmBlueOnWhite : List Css.Snippet
elmBlueOnWhite =
    [ body
        [ padding zero
        , margin zero
        , height (pct 100)
        , backgroundColor bgColor
        , color txtColor
        , fontFamilies [ "calibri", "sans-serif" ]
        , fontSize font
        ]
    , h1
        [ fontSize (px 38)
        ]
    , section
        [ height (px 700)
        , width (pct 100)
        , backgroundColor bgColor
        , property "background-position" "center"
        , property "background-size" "cover"
        , displayFlex
        , property "justify-content" "center"
        , alignItems center
        ]
    , class "slide-content"
        [ margin2 zero (px 90)
        ]
    , code
        [ textAlign left
        , fontSize font
        , backgroundColor codeBgColor
        ]
    , Css.Elements.pre
        [ padding (px 20)
        , fontSize font
        , backgroundColor codeBgColor
        ]
    , img
        [ width (pct 100)
        ]
    ]


main =
    Slides.app
        { slidesDefaultOptions
            | style = elmBlueOnWhite
        }
        [ md
            """
            # Composing a pizza:
            ### Decoders ang generators in Elm
            """
        , mdFragments
            [ """
              A generator is something that (duh!) generates values:

              ```elm
              generator =
                  Random.int 1 10

              (aRandomIntegerValue, newSeed) =
                  Random.step generator oldSeed
              ```
              """
            ]
        , mdFragments
            [ """
              Problem: how do I generate complex stuff?
              """
            , """
                ```elm
                type Topping =
                    Onion | Mushroom | Sausage

                type alias Pizza =
                    { cheeseCount : Int
                    , mainTopping : Topping
                    , extraTopping : Maybe Topping
                    }
                ```
              """
            ]
        , md
            """
                ```elm
                generatePizza seed0 =
                    let
                        (seed1, cheeseCount) =
                            Random.step (Random.int 0 4) seed0

                        (seed2, mainToppingIndex) =
                            Random.step (Random.int 0 2) seed1

                        (seed3, extraToppingIndex) =
                            Random.step (Random.int 0 2) seed2

                        (seed4, hasExtraTopping) =
                            Random.step Random.bool seed3

                        mainTopping =
                            int2topping mainToppingIndex

                        extraTopping =
                            if hasExtraTopping
                            then Just (int2topping extraToppingIndex)
                            else Nothing

                        randomPizza =
                            Pizza cheeseCount mainTopping extraTopping
                    in
                        (randomPizza, seed3)
                ```
              """
        , mdFragments
            [ " * I made a mistake, did you see it?"
            , " * Lugging around the `seedX` value is a pain!"
            , " * It is cluttered and difficult to read!"
            , " * I generate `extraToppingIndex` even when I don't use it"
            ]
        , mdFragments
            [ "Coming from imperative languages, we are used to compose *values*."
            , "➡ But in a functional language, we compose *functions*."
            ]
        , md
            """
            # A different way of thinking
            """
        , mdFragments
            [ """
                ```elm
                List.map : (a -> b) -> List a -> List b
                ```
              """
            , """
                ```elm
                List.map : (a -> b) -> (List a -> List b)
                ```
              """
            , "`map` is transforming a function into another function!"
            ]
        , mdFragments
            [ """
                What happens if we apply `map` to `toFloat`?
                ```elm
                toFloat : Int -> Float
                ```
              """
            , """
                ```elm
                (List.map toFloat) : List Int -> List Float
                ```
              """
            , """
                We can use it with other "containers":
                ```elm
                (Maybe.map toFloat) : Maybe Int -> Maybe Float
                ```
              """
            ]
        , mdFragments
            [ """
                ![function f](images/f.png)

                ![map f](images/mapf.png)
              """
            ]
        , mdFragments
            [ """
                ```elm
                int2topping : Int -> Topping

                (List.map int2topping) : List Int -> List Topping

                (Maybe.map int2topping) : Maybe Int -> Maybe Topping
                ```
              """
            , """
                ```elm
                (Random.map int2topping) : Generator Int -> Generator Topping
                ```
              """
            ]
        , mdFragments
            [ "Let's implement it!"
            , """
                ```elm
                type Topping = Onion | Mushroom | Sausage
                ```
              """
            , """
                ```elm
                int2topping : Int -> Topping
                int2topping index =
                    case index of
                        0 -> Onion
                        1 -> Mushroom
                        _ -> Sausage
                ```
              """
            , """
                ```elm
                (Random.map int2topping) : Generator Int -> Generator Topping
                ```
              """
            , """
                ```elm
                toppingGenerator : Generator Topping
                toppingGenerator =
                    Random.map int2topping
                        (Random.int 0 2)
                ```
              """
            ]
        , md
            """
                What if our function has more than 1 argument?

                ![pizza](images/pizza.png)
            """
        , md
            """
            ![map3 Pizza](images/map3pizza.png)
            """
        , mdFragments
            [ """
                ```elm
                (List.map3 Pizza) :
                    List Int ->
                    List Topping ->
                    List (Maybe Topping) ->
                    List Pizza

                (Maybe.map3 Pizza) :
                    Maybe Int ->
                    Maybe Topping ->
                    Maybe (Maybe Topping) ->
                    Maybe Pizza
                ```
              """
            , """
                ```elm
                (Random.map3 Pizza) :
                    Generator Int ->
                    Generator Topping ->
                    Generator (Maybe Topping) ->
                    Generator Pizza
                ```
              """
            ]
        , mdFragments
            [ "Let's implement it!"
            , """
                ```elm
                (Random.map3 Pizza) :
                    Generator Int ->
                    Generator Topping ->
                    Generator (Maybe Topping) ->
                    Generator Pizza
                ```
              """
            , """
                ```elm
                pizzaGenerator : Generator Pizza
                pizzaGenerator =
                    Random.map3 Pizza
                        (Random.int 0 4)
                        toppingGenerator
                        (Random.Extra.maybe Random.bool toppingGenerator)
                ```
              """
            , """
                ```elm
                maybe : Generator Bool -> Generator a -> Generator (Maybe a)
                ```
              """
            ]
        , mdFragments
            [ """
                ```elm
                pizzaGenerator : Generator Pizza
                pizzaGenerator =
                    Random.map3 Pizza
                        (Random.int 0 4)
                        toppingGenerator
                        (Random.Extra.maybe Random.bool toppingGenerator)
                ```
              """
            , """
              ➡ Very clear, very readable
              """
            , """
              ➡ No messing with seeds
              """
            ]
        , mdFragments
            [ """
                This way of composing functions is very general!

                ```elm
                pizzaGenerator : Generator Pizza
                pizzaGenerator =
                    Random.map3
                        Pizza
                        (Random.int 0 4)
                        toppingGenerator
                        (Random.Extra.maybe Random.bool toppingGenerator)
                ```

                ```elm
                pizzaJsonDecoder : Json.Decode.Decoder Pizza
                pizzaJsonDecoder =
                    Json.Decode.object3 Pizza
                        ("cheeseCount" := Json.Decode.int)
                        ("mainTopping" := toppingDecoder)
                        (Json.Decode.maybe ("extraTopping" := toppingDecoder))
                ```
                (`Json.Decode.object3` will be renamed to `map3` in Elm 0.18)
              """
            ]
        , mdFragments
            [ """
              @xarvh
              ------

              https://github.com/xarvh/talk-generators
              """
            ]
        ]
