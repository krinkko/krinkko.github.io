-- USERID


module UserId exposing
    ( UserId
    , parseUserId
    , servername
    , toString
    , toUserIdDecoder
    , userIdParser
    , username
    , validLocalpartChar
    , validServernameChar
    )

import Json.Decode as JD
import Parser exposing ((|.), (|=), Parser)
import Set


{-| User Id parsing implemented based on the identifier grammar described in the spec:
<https://matrix.org/docs/spec/appendices#identifier-grammar>
-}
type UserId
    = UserId String String


toString : UserId -> String
toString (UserId localpart serverpart) =
    "@" ++ localpart ++ ":" ++ serverpart


{-| Convert a JSON string decoder to a JSON UserId Decoder
-}
toUserIdDecoder : JD.Decoder String -> JD.Decoder UserId
toUserIdDecoder =
    JD.andThen
        (\s ->
            case parseUserId s of
                Ok userid ->
                    JD.succeed userid

                Err e ->
                    JD.fail e
        )


parseUserId : String -> Result String UserId
parseUserId =
    String.toLower
        >> Parser.run userIdParser
        >> Result.mapError (\_ -> "Must follow format: @user:example.com")


username : UserId -> String
username (UserId name _) =
    name


servername : UserId -> String
servername (UserId _ name) =
    name


validLocalpartChar : Char -> Bool
validLocalpartChar c =
    Char.isLower c
        || Char.isDigit c
        || List.member c [ '-', '.', '=', '_', '/' ]


validServernameChar : Char -> Bool
validServernameChar c =
    Char.isAlphaNum c || List.member c [ '.', '-', ':' ]


userIdParser : Parser UserId
userIdParser =
    Parser.succeed UserId
        |. Parser.token "@"
        |= Parser.variable
            { start = validLocalpartChar
            , inner = validLocalpartChar
            , reserved = Set.empty
            }
        |. Parser.token ":"
        |= Parser.variable
            { start = validServernameChar
            , inner = validServernameChar
            , reserved = Set.empty
            }
        |. Parser.end
