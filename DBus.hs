{-# LANGUAGE OverloadedStrings #-}

import System.Posix.User
import Network.DBus
import Network.DBus.Actions
import Network.DBus.Message
import Network.DBus.StdMessage
import Network.DBus.Type
import Network.DBus.Signature
import Data.Word
import Control.Monad.Trans


mainDBus uid = do
	ctx <- busGetSession
	authenticateUID ctx uid

	messageSend ctx (msgDBusHello)
	messageRecv ctx
	liftIO $ putStrLn "spurious"
	messageRecv ctx

	messageSend ctx msgDBusListNames
	msg <- messageRecv ctx
	let b = readBody msg
	liftIO $ putStrLn $ show b

	let msg = msgMethodCall "org.freedesktop.Notifications" "/org/freedesktop/Notifications" "org.freedesktop.Notifications" "Notify"
		[ DBusString "y"
		, DBusUInt32 1
		, DBusString "x"
		, DBusString "this is a string"
		, DBusString "this is a o----"
		, DBusArray (SigString) []
		, DBusArray (SigDict SigString SigVariant) []
		, DBusInt32 4000
		]

	liftIO $ putStrLn $ show msg
	messageSend ctx msg
	msgR <- messageRecv ctx
	liftIO $ putStrLn $ show msgR

main = getRealUserID >>= mainDBus . fromIntegral
