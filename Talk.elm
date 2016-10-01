import Slides exposing (..)


main =
    Slides.app
        slidesDefaultOptions
        [ md
            "# Using (random) generators"

        , md
            """
            A generator is something that (duh!) generates values:

            ```
            generator =
                Random.int 1 10

            (aRandomIntegerValue, newSeed) =
                Random.step generator oldSeed
            ```
            """

        , md
            """
            How do we use this to generate a complex type?
            """

        , md
            """
            ```
            generateSample seed0 =
                let
                    (seed1, age) =
                        Random.step (Random.int 1 1000) seed0

                    (seed2, latitude) =
                        Random.step (Random.float -90 +90) seed1

                    (seed3, longitude) =
                        Random.step (Random.float -180 +180) seed2

                    randomSample =
                        Sample age latitude longitude
                in
                    (randomSample, seed3)
            ```
            """

        , md
            """
            We see at once a problem: having to lug around that seed
            is a pain in the ass!
            """

        , mdFragments
            [ "Coming from imperative languages, we are used to compose *values*."
            , "-> But in a functional language, we compose *functions*."
            ]

        , md
            """
            # A different way of thinking
            """

        , mdFragments
            [ """
                ```
                List Int
                Maybe Int
                ```
              """
            , """
                They are "containers" of `Int`

                We can use `map` to manipulate that `Int`
              """
            , """
                `(List.map toString) : List Int -> List String`

                `(Maybe.map toString) : Maybe Int -> Maybe String`
              """
            , "(This is also true for pretty much every type with a `map`)"
            ]

        , mdFragments
            [ """
               ```
               List Int
               Maybe Int
               Generator Int
               ```
              """
            , """
                ```
               (List.map toString) : List Int -> List String
               (Maybe.map toString) : Maybe Int -> Maybe String
               (Random.map toString) : Generator Int -> Generator String
               ```
              """
            ]

        , md
            """
           `map` allows us to work with the value without having it!
            """

        , md
            """
            How can we use this to generate more complex stuff?
            """

        , md
            """
               ```
               sampleGenerator =
                   Random.map3
                       \\age latitude longitude -> Sample age latitude longitude
                       (Random.int 1 1000)
                       (Random.float -90 +90)
                       (Random.float -180 +180)
               ```
            """

        , mdFragments
            [ """
               ```
               sampleGenerator : Generator Sample
               sampleGenerator =
                   Random.map3
                       Sample
                       (Random.int 1 1000)
                       (Random.float -90 +90)
                       (Random.float -180 +180)
               ```
              """
            , "-> no dangerous fumbling around with seeds"
            , "-> no clutter"
            ]

        , mdFragments
            [ "What if a child generator needs random parameters?"
            , """
               ```
               sampleGenerator : Generator Sample
               sampleGenerator =
                   Random.bool `Random.andThen` \\isVeryOld - >
                       Random.map3
                           Sample
                           (Random.int 1 (if isVeryOld then 1000000 else 1000)
                           (Random.float -90 +90)
                           (Random.float -180 +180)
               ```
              """
            ]

        , mdFragments
            [ "We can do pretty much everything by combining `map` and `andThen`"
            , """
                ```
                map2 mapper genA genB =
                    genA `andThen` \a ->
                        map (mapper a) genB
                ```
              """
            ]

        , mdFragments
            [ "This is the same pattern used for:"
            , " * Generators (random or otherwise)"
            , " * Encoders, Decoders, Parsers"
            ]
        , md
            """
               See Generators as something more abstract:
               ```
                   (aRandomThing, newSeed) =
                       Random.step randomThingGenerator oldSeed
               ```
            """

        , md
            """
               One last problem remaining:

               How the hell do I initialise that seed?
            """
        ]

{-

   $
       ```
       Html.App.programWithFlags
           { init = init
           , update = update
           , subscriptions = subscriptions
           , view = view
           }
       ```

       ```
           <script type="text/javascript">Elm.Main.fullscreen(Date.now())</script>
       ```


   $
       ```
       init : Int -> ( Model, Cmd Msg )
       init dateNow =
           let
               seed = Random.initialSeed dateNow
           in
               ( makeModel seed, Cmd.none )
       ```


   $
       lexical-name-generator


   $
       @xarvh



-}
