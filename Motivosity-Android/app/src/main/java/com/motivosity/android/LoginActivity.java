package com.motivosity.android;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.annotation.TargetApi;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.support.annotation.NonNull;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.app.LoaderManager.LoaderCallbacks;

import android.content.CursorLoader;
import android.content.Loader;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.AsyncTask;

import android.os.Build;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.EditorInfo;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.appindexing.Action;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.common.api.GoogleApiClient;
import com.manavo.rest.RestCallback;
import com.manavo.rest.RestErrorCallback;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import static android.Manifest.permission.READ_CONTACTS;

/**
 * A login screen that offers login via email/password.
 */
public class LoginActivity extends AppCompatActivity {

    /**
     * Id to identity READ_CONTACTS permission request.
     */
    private static final int REQUEST_READ_CONTACTS = 0;

    /**
     * A dummy authentication store containing known user names and passwords.
     * TODO: remove after connecting to a real authentication system.
     */

    /**
     * Keep track of the login task to ensure we can cancel it if requested.
     */
    // UI references.
    private EditText mEmailView;
    private EditText mPasswordView;
    private EditText txtRoot;
    private EditText txtResourceRoot;
    private View mLoginFormView;
    private View mLoginView;

    ImageView logoImage;
    Long downTimeStamp, upTimeStamp;

    String username, password;
    public LoginActivity loginInstance = null;
    /**
     * ATTENTION: This was auto-generated to implement the App Indexing API.
     * See https://g.co/AppIndexing/AndroidStudio for more information.
     */
    private GoogleApiClient client;
    Timer timer;
    class setConfigTask extends TimerTask {

        @Override
        public void run() {
            loginInstance.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    timer.cancel();
                    timer = null;
                    txtRoot.setVisibility(View.VISIBLE);
                    txtResourceRoot.setVisibility(View.VISIBLE);
                }
            });

        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        // Set up the login form.
        mEmailView = (EditText) findViewById(R.id.email);
        mPasswordView = (EditText) findViewById(R.id.password);
        txtRoot = (EditText) findViewById(R.id.txtRoot);
        txtResourceRoot = (EditText) findViewById(R.id.txtResourceRoot);

        txtRoot.setText(MainActivity.ResourceStagingRootUrl);
        txtResourceRoot.setText(MainActivity.ResourceRootUrl);

        logoImage = (ImageView) findViewById(R.id.logoImage);

        logoImage.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                int action = event.getAction();
                switch (action) {
                    case MotionEvent.ACTION_DOWN:
                        downTimeStamp = System.currentTimeMillis()/1000;
                        if (timer!=null){
                            timer.cancel();
                            timer = null;
                        }
                        timer = new Timer();
                        timer.schedule(new setConfigTask(), 10000, 1000);
                        break;
                    case MotionEvent.ACTION_UP:
                        if (timer!=null){
                            timer.cancel();
                            timer = null;
                        }
                        break;
                }
    /*
     * Return 'true' to indicate that the event have been consumed.
     * If auto-generated 'false', your code can detect ACTION_DOWN only,
     * cannot detect ACTION_MOVE and ACTION_UP.
     */
                return true;
            }
        });

        Button mEmailSignInButton = (Button) findViewById(R.id.email_sign_in_button);
        mEmailSignInButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                mLoginView = view;
                MainActivity.ResourceStagingRootUrl = txtRoot.getText().toString();
                MainActivity.ResourceRootUrl = txtResourceRoot.getText().toString();
                attemptLogin();
            }
        });

        mLoginFormView = findViewById(R.id.email_login_form);
        loginInstance = this;
        JSONObject userinfo = getLoginCredential();
        if(userinfo != null) {
            try {
                username = userinfo.getString("username");
                password = userinfo.getString("password");
                userLogin(username, password);
            }catch(JSONException e) {}
        }

        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        client = new GoogleApiClient.Builder(this).addApi(AppIndex.API).build();
    }

    /**
     * Attempts to sign in or register the account specified by the login form.
     * If there are form errors (invalid email, missing fields, etc.), the
     * errors are presented and no actual login attempt is made.
     */
    private void attemptLogin() {

        // Reset errors.
        mEmailView.setError(null);
        mPasswordView.setError(null);

        // Store values at the time of the login attempt.
        String email = mEmailView.getText().toString();
        String password = mPasswordView.getText().toString();

        boolean cancel = false;
        View focusView = null;

        // Check for a valid password, if the user entered one.
        if (!TextUtils.isEmpty(password) && !isPasswordValid(password)) {
            mPasswordView.setError(getString(R.string.error_invalid_password));
            focusView = mPasswordView;
            cancel = true;
        }

        // Check for a valid email address.
        if (TextUtils.isEmpty(email)) {
            mEmailView.setError(getString(R.string.error_field_required));
            focusView = mEmailView;
            cancel = true;
        } else if (!isEmailValid(email)) {
            mEmailView.setError(getString(R.string.error_invalid_email));
            focusView = mEmailView;
            cancel = true;
        }

        if (cancel) {
            // There was an error; don't attempt login and focus the first
            // form field with an error.
            focusView.requestFocus();
        } else {
            // Show a progress spinner, and kick off a background task to
            // perform the user login attempt.
            this.username = email;
            this.password = password;
            userLogin(email, password);
//            mAuthTask = new UserLoginTask(email, password);
//            mAuthTask.execute((Void) null);
        }
    }

    private boolean isEmailValid(String email) {
        //TODO: Replace this with your own logic
        return email.contains("@");
    }

    private boolean isPasswordValid(String password) {
        //TODO: Replace this with your own logic
        return true;
    }

    public void getUser(final String accessToken) {
        MotivosityAPI api = new MotivosityAPI(this);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                try {
                    JSONObject data = new JSONObject(obj.toString());
                    if (data.has("id")) {
                        MainActivity.userAvatarUrl = data.getString("avatarUrl");
                        MainActivity.userFullName = data.getString("fullName");
                        getUserCash(accessToken);
                    } else {
                        Toast.makeText(loginInstance, data.getString("message"), Toast.LENGTH_LONG).show();
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    Toast.makeText(loginInstance, obj.toString(), Toast.LENGTH_LONG).show();
                }
            }
        });
        api.setErrorCallback(new RestErrorCallback() {
            @Override
            public void error(String data) {
                String message;
                int code;
                // try to read the JSON Object. If it fails, just show the data.
                try {
                    JSONObject obj = new JSONObject(data);
                    message = obj.getString("message");
                    code = obj.getInt("code");
                } catch (JSONException e) {
                    e.printStackTrace();
                    message = data;
                    code = -1;
                }

                Toast.makeText(loginInstance, message, Toast.LENGTH_LONG).show();
            }
        });
        api.setLoadingMessage("Loading user information...");
        api.currentUser(accessToken);
    }

    public void getUserCash(String accessToken) {
        MotivosityAPI api = new MotivosityAPI(this);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                try {
                    JSONObject data = new JSONObject(obj.toString());
                    if (data.has("cashGiving") && data.has("cashReceiving")) {
                        Intent i = new Intent(loginInstance, MainActivity.class);
                        startActivity(i);
                        MainActivity.cashGiving = data.getString("cashGiving");
                        MainActivity.cashReceiving = data.getString("cashReceiving");
                        MainActivity.mMoreFragment = null;
                        MainActivity.mHomeFragment = null;
                        MainActivity.mStoreFragment = null;
                        MainActivity.mThanksFragment = null;
                    } else {
                        Toast.makeText(loginInstance, data.getString("message"), Toast.LENGTH_LONG).show();
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    Toast.makeText(loginInstance, obj.toString(), Toast.LENGTH_LONG).show();
                }
            }
        });
        api.setErrorCallback(new RestErrorCallback() {
            @Override
            public void error(String data) {
                String message;
                int code;
                // try to read the JSON Object. If it fails, just show the data.
                try {
                    JSONObject obj = new JSONObject(data);
                    message = obj.getString("message");
                    code = obj.getInt("code");
                } catch (JSONException e) {
                    e.printStackTrace();
                    message = data;
                    code = -1;
                }

                Toast.makeText(loginInstance, message, Toast.LENGTH_LONG).show();
            }
        });
        api.setLoadingMessage("Loading user balance...");
        api.userCash(accessToken);
    }

    public void userLogin(String email, String password) {
        MotivosityAPI api = new MotivosityAPI(this);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                try {
                    JSONObject data = new JSONObject(obj.toString());
                    if (data.getBoolean("success")) {
                        storeLoginCredential(data.getString("token"), MainActivity.ResourceRootUrl, MainActivity.ResourceStagingRootUrl);
                        getUser(data.getString("token"));
                    } else {
                        Toast.makeText(loginInstance, data.getString("message"), Toast.LENGTH_LONG).show();
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    Toast.makeText(loginInstance, obj.toString(), Toast.LENGTH_LONG).show();
                }
            }
        });
        api.setErrorCallback(new RestErrorCallback() {
            @Override
            public void error(String data) {
                String message;
                int code;
                // try to read the JSON Object. If it fails, just show the data.
                try {
                    JSONObject obj = new JSONObject(data);
                    message = obj.getString("message");
                    code = obj.getInt("code");
                } catch (JSONException e) {
                    e.printStackTrace();
                    message = data;
                    code = -1;
                }

                Toast.makeText(loginInstance, message, Toast.LENGTH_LONG).show();
            }
        });
        api.logIn(email, password);
    }

    /**
     * Shows the progress UI and hides the login form.
     */
    private void storeLoginCredential(String accessToken, String ResourceRootUrl, String RootUrl) {
        SharedPreferences sp = getSharedPreferences("Login", 0);
        SharedPreferences.Editor Ed = sp.edit();
        Ed.putString("accessToken", accessToken);
        Ed.putString("username", username);
        Ed.putString("password", password);
        Ed.putString("resourceRootUrl", ResourceRootUrl);
        Ed.putString("rootUrl", RootUrl);
        Ed.commit();
    }

    private JSONObject getLoginCredential() {
        SharedPreferences sp1 = this.getSharedPreferences("Login", 0);
        String username = sp1.getString("username", null);
        String password = sp1.getString("password", null);
        String accessToken = sp1.getString("accessToken", null);
        MainActivity.ResourceRootUrl = sp1.getString("resourceRootUrl", null);
        MainActivity.ResourceStagingRootUrl = sp1.getString("rootUrl", null);

        if(username == null || password== null || accessToken==null)
            return null;

        JSONObject userinfo = new JSONObject();
        try {
            userinfo.put("username", username.toString());
            userinfo.put("password", password.toString());
            userinfo.put("accessToken", accessToken.toString());
        } catch(JSONException e) {

        }

        return userinfo;
    }

    @Override
    public void onStart() {
        super.onStart();

        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        client.connect();
        Action viewAction = Action.newAction(
                Action.TYPE_VIEW, // TODO: choose an action type.
                "Login Page", // TODO: Define a title for the content shown.
                // TODO: If you have web page content that matches this app activity's content,
                // make sure this auto-generated web page URL is correct.
                // Otherwise, set the URL to null.
                Uri.parse("http://host/path"),
                // TODO: Make sure this auto-generated app deep link URI is correct.
                Uri.parse("android-app://com.motivosity.android/http/host/path")
        );
        AppIndex.AppIndexApi.start(client, viewAction);
    }

    @Override
    public void onStop() {
        super.onStop();

        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        Action viewAction = Action.newAction(
                Action.TYPE_VIEW, // TODO: choose an action type.
                "Login Page", // TODO: Define a title for the content shown.
                // TODO: If you have web page content that matches this app activity's content,
                // make sure this auto-generated web page URL is correct.
                // Otherwise, set the URL to null.
                Uri.parse("http://host/path"),
                // TODO: Make sure this auto-generated app deep link URI is correct.
                Uri.parse("android-app://com.motivosity.android/http/host/path")
        );
        AppIndex.AppIndexApi.end(client, viewAction);
        client.disconnect();
    }
}

