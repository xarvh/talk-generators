
Learn to love Generators
========================


$
    A generator is something that (duh!) generates values:

    ```
    (aRandomIntegerValue, newSeed) =
        Random.step (Random.int 1 10) oldSeed
    ```


$
    How do we use this to generate a complex type?


$
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

$
    We see at once a problem: having to lug around that seed
    is a pain in the ass!





$
    Coming from imperative languages, we are used to compose *values*.

    -> But in a functional language, we compose *functions*.


$
    A different way of thinking
    ===========================

        List Int
        Maybe Int

        They are "containers" of Int
        We can use `map` to manipulate that Int

        (List.map toString) : List Int -> List String
        (Maybe.map toString) : Maybe Int -> Maybe String

        (This is also true for pretty much every type with a `map`)


$
        List Int
        Maybe Int
        Generator Int

        (List.map toString) : List Int -> List String
        (Maybe.map toString) : Maybe Int -> Maybe String
        (Random.map toString) : Generator Int -> Generator String

$
        `map` allows us to work with the value without having it!

$
        How can we use this to generate more complex stuff?

$
        ```
        sampleGenerator =
            Random.map3
                \age latitude longitude -> Sample age latitude longitude
                (Random.int 1 1000)
                (Random.float -90 +90)
                (Random.float -180 +180)
        ```

$
        ```
        sampleGenerator : Generator Sample
        sampleGenerator =
            Random.map3
                Sample
                (Random.int 1 1000)
                (Random.float -90 +90)
                (Random.float -180 +180)
        ```
        - no dangerous fumbling around with seeds
        - no clutter



$
        What if a child generator needs random parameters?
        ```
        sampleGenerator : Generator Sample
        sampleGenerator =
            Random.bool `Random.andThen` \isVeryOld ->
                Random.map3
                    Sample
                    (Random.int 1 (if isVeryOld then 1000000 else 1000)
                    (Random.float -90 +90)
                    (Random.float -180 +180)
        ```


$

    see Generators as something that we use with
    ```
        (aRandomThing, newSeed) =
            Random.step randomThingGenerator oldSeed
    ```


$
    Last thing:
    How the hell do I initialise that seed?


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
    @xarvh














