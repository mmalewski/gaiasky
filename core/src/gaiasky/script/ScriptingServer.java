/*
 * This file is part of Gaia Sky, which is released under the Mozilla Public License 2.0.
 * See the file LICENSE.md in the project root for full license details.
 */

package gaiasky.script;

import com.badlogic.gdx.Gdx;
import gaiasky.event.EventManager;
import gaiasky.event.Events;
import gaiasky.util.Logger;
import py4j.*;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * The scripting server of Gaia Sky, backed by a Py4J {@link py4j.GatewayServer}.
 */
public class ScriptingServer {
    private static final Logger.Log logger = Logger.getLogger(ScriptingServer.class);

    private static ClientServer gatewayServer;
    private static GatewayServerListener listener;
    private static AtomicInteger connections = new AtomicInteger(0);

    public static void initialize() {
        initialize(false);
    }

    public static void initialize(boolean force) {
        if (force && gatewayServer != null) {
            // Shutdown
            try {
                dispose();
            } catch (Exception e) {
                logger.error(e);
            }
        }
        if (gatewayServer == null) {
            gatewayServer = new ClientServer(EventScriptingInterface.instance());
            listener = new DefaultGatewayServerListener() {

                @Override
                public void connectionStarted(Py4JServerConnection gatewayConnection) {
                    logger.info("Connection started (" + connections.incrementAndGet() + "): " + gatewayConnection.getSocket().toString());
                }

                @Override
                public void connectionStopped(Py4JServerConnection gatewayConnection) {
                    // Enable input, just in case
                    Gdx.app.postRunnable(() -> EventManager.instance.post(Events.INPUT_ENABLED_CMD, true));
                    logger.info("Connection stopped (" + connections.decrementAndGet() + "): " + gatewayConnection.getSocket().toString());
                }

                @Override
                public void serverPostShutdown() {
                    logger.debug("Post shutdown");
                }

                @Override
                public void serverPreShutdown() {
                    logger.debug("Pre shutdown");
                }

                @Override
                public void serverStarted() {
                    logger.info("Server started on port " + gatewayServer.getJavaServer().getListeningPort());
                }

                @Override
                public void serverStopped() {
                    logger.info("Server stopped");
                    initialize(true);
                }

                @Override
                public void connectionError(Exception e) {
                    logger.error(e);
                }

                @Override
                public void serverError(Exception e) {
                    logger.error(e);
                    initialize(force);
                }
            };
            gatewayServer.getJavaServer().addListener(listener);
        }
        try {
            gatewayServer.startServer();
        } catch (Exception e) {
            logger.error("Could not initialize the Py4J gateway server, is there another instance of Gaia Sky running?");
            logger.error(e);
        }
    }

    public static void dispose() {
        if (gatewayServer != null) {
            if (listener != null) {
                gatewayServer.getJavaServer().removeListener(listener);
                listener = null;
            }
            gatewayServer.shutdown();
            gatewayServer = null;
        }
    }
}