package com.comp2601.chatclient;

import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.WebSocket;
import okhttp3.WebSocketListener;
import okio.ByteString;

public class MainActivity extends AppCompatActivity {

    //server url string for AVD accessing server running on local host machine
    public static final String SERVER_URL_STRING = "ws://10.0.2.2:3000";

    //TODO: add IP address and Port for classroom server if you want to talk to it

    private static final String TAG = "MainActivity";
    private static final int NORMAL_CLOSURE_STATUS = 1000;


    private TextView mTextViewMsgOutput;
    private EditText mEditViewMsgSend;
    private Button mButtonSendMsg;
    private Button mButtonConnect;
    private Button mButtonDisconnect;
    private OkHttpClient mClient;
    private WebSocket mWs;



    public void enableButtons(Button mButton1, Button mButton2) {
        mButton1.setEnabled(true);
        mButton2.setEnabled(true);
    }

    public void enableButtons(Button mButton) {
        mButton.setEnabled(true);
    }

    public void disableButtons(Button mButton) {
        mButton.setEnabled(false);
    }

    public void disableButtons(Button mButton1, Button mButton2) {
        mButton1.setEnabled(false);
        mButton2.setEnabled(false);

    }

    //TODO: Create your own subclass of WebSocketListener
    private final class ChatWebSocketListener extends WebSocketListener {

        @Override
        public void onOpen(WebSocket webSocket, Response response) {
            webSocket.send("Hello from Android Client: " + Build.MANUFACTURER + " " + Build.MODEL);
            //webSocket.send("What's up ?");
            //webSocket.send(ByteString.decodeHex("deadbeef"));

        }
        @Override
        public void onMessage(WebSocket webSocket, String text) {
            output("Receiving : " + text);
        }
        @Override
        public void onMessage(WebSocket webSocket, ByteString bytes) {
            output("Receiving bytes : " + bytes.hex());
        }
        @Override
        public void onClosing(WebSocket webSocket, int code, String reason) {
            webSocket.close(NORMAL_CLOSURE_STATUS, null);
            output("Closing Server Connection : " + code + " / " + reason);
        }
        @Override
        public void onFailure(WebSocket webSocket, Throwable t, Response response) {
            output("Error : " + t.getMessage());
        }
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mTextViewMsgOutput = (TextView) findViewById(R.id.msgRecievedView);
        mEditViewMsgSend = (EditText) findViewById(R.id.editTextMsgSend);
        mButtonSendMsg = (Button) findViewById(R.id.buttonSend);
        mButtonConnect = (Button) findViewById(R.id.buttonConnect);
        mButtonDisconnect = (Button) findViewById(R.id.buttonDisconnect);

        disableButtons(mButtonSendMsg, mButtonDisconnect);

        //TODO: Create an OkHttpClient
        mClient = new OkHttpClient();

        mTextViewMsgOutput.setMovementMethod(new ScrollingMovementMethod());
        mButtonConnect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                enableButtons(mButtonSendMsg, mButtonDisconnect);

                disableButtons(mButtonConnect);

                //TODO: Use OkHttpClient to create a Web Socket connected to Chat Server
                Request request = new Request.Builder().url(SERVER_URL_STRING).build();
                ChatWebSocketListener listener = new ChatWebSocketListener();
                mWs = mClient.newWebSocket(request, listener);



            }
        });

        mButtonSendMsg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                String message = mEditViewMsgSend.getText().toString();
                //TODO: Send Message to Server via Web Socket
                if(mWs != null)
                    mWs.send(message);

                mEditViewMsgSend.setText("");
            }
        });

        mButtonDisconnect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                enableButtons(mButtonConnect);
                disableButtons(mButtonSendMsg, mButtonDisconnect);

                //TODO: Close the Web Socket
                mWs.close(NORMAL_CLOSURE_STATUS, "Goodbye !");
                //mClient.dispatcher().executorService().shutdown();
                //mClientConnection.stopClient();


            }
        });


    }


    private void output(final String txt) {
        /*
          This method will output contents on the mTextViewMsgOutput but run the request
          on the UIThread. This can be called from with a WebSocketClient which runs
          on its own thread.
         */
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mTextViewMsgOutput.setText(mTextViewMsgOutput.getText().toString() + "\n\n" + txt);
            }
        });
    }

}
