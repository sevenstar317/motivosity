package com.motivosity.android;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.*;

import com.manavo.rest.RestCallback;
import com.manavo.rest.RestErrorCallback;
import com.squareup.picasso.Picasso;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;


public class ThanksFragment extends Fragment implements OnClickListener {
    public static String TAG = "Thanks_Fragment";
    JSONArray userList;
    JSONArray companyList;
    UserListAdapter adapter;

    public String choosedUserId;
    public String choosedUserName;

    EditText txtUserName;
    ImageView userAvatarImg;
    ListView listView;
    View view;


    TextView txtPost;
    EditText txtAmount;
    EditText txtComment;
    Spinner comapnySpinner;
    LinearLayout commentWrapper;
    Timer timer;


    class getUserListTask extends TimerTask {

        @Override
        public void run() {
            MainActivity.instance.runOnUiThread(new Runnable() {

                @Override
                public void run() {
                    timer.cancel();
                    timer = null;
                    if (!txtUserName.getText().toString().equals("") && choosedUserId == null)
                        getUserList(txtUserName.getText().toString());
                }
            });

        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {

        view = inflater.inflate(R.layout.fragment_thanks, container, false);


        txtUserName = (EditText) view.findViewById(R.id.userName);
        txtAmount = (EditText) view.findViewById(R.id.txtAmount);
        txtComment = (EditText) view.findViewById(R.id.txtComment);
        comapnySpinner = (Spinner) view.findViewById(R.id.spinner);

        userAvatarImg = (ImageView) view.findViewById(R.id.userAvatar);
        listView = (ListView) view.findViewById(R.id.listView2);
        listView.setVisibility(View.INVISIBLE);
        txtPost = (TextView) view.findViewById(R.id.txtPost);
        commentWrapper = (LinearLayout) view.findViewById(R.id.commentWrapper);


        txtPost.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                InputMethodManager inputMethodManager = (InputMethodManager)  MainActivity.instance.getSystemService(Activity.INPUT_METHOD_SERVICE);
                inputMethodManager.hideSoftInputFromWindow(MainActivity.instance.getCurrentFocus().getWindowToken(), 0);
                try {
                    JSONObject comapnyValue = (JSONObject) companyList.get(comapnySpinner.getSelectedItemPosition());
                    String companyId = comapnyValue.getString("id");
                    String amount = txtAmount.getText().toString();
                    String comment = txtComment.getText().toString();
                    if(companyId.isEmpty() || comment.isEmpty()) {
                        Toast.makeText(view.getContext(), "Please enter a note", Toast.LENGTH_LONG).show();
                    } else {
                        if(amount.isEmpty())
                            amount="0";
                        SaveAppreciation(companyId, amount, comment);
                    }
                } catch(JSONException e) {}
            }
        });



        TextWatcher watcher= new TextWatcher() {
            public void afterTextChanged(Editable s) {
                if (!txtUserName.getText().toString().equals("")) {
                    if (timer!=null){
                        timer.cancel();
                        timer = null;
                    }
                    timer = new Timer();
                    timer.schedule(new getUserListTask(), 2000, 1000);
                }

            }
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                //Do something or nothing.
            }
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                //Do something or nothing
            }
        };

        txtUserName.addTextChangedListener(watcher);

        txtUserName.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                //You can identify which key pressed buy checking keyCode value with KeyEvent.KEYCODE_
                if (keyCode == KeyEvent.KEYCODE_DEL) {
                    //this is for backspace
                    listView.setVisibility(View.INVISIBLE);
                    userAvatarImg.setVisibility(View.INVISIBLE);
                    txtUserName.setText("", EditText.BufferType.EDITABLE);
                    choosedUserId = null;
                } else if (keyCode == KeyEvent.KEYCODE_ENTER) {
                    if (!txtUserName.getText().toString().isEmpty() && choosedUserId==null) {
                        getUserList(txtUserName.getText().toString());
                    } else if (choosedUserId !=null) {
                        txtUserName.setText(choosedUserName, EditText.BufferType.EDITABLE);
                    }
                }
                return false;
            }
        });

        txtUserName.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (((EditText) v).getId() == txtUserName.getId() && hasFocus) {
                    if (!txtUserName.getText().toString().isEmpty()) {
                        listView.setVisibility(View.VISIBLE);
                    }
                } else {
                    listView.setVisibility(View.INVISIBLE);
                }
            }
        });

        txtAmount.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                //You can identify which key pressed buy checking keyCode value with KeyEvent.KEYCODE_
                if (keyCode == KeyEvent.KEYCODE_ENTER || keyCode == KeyEvent.KEYCODE_NAVIGATE_NEXT) {
                    commentWrapper.setVisibility(View.VISIBLE);
                }
                return false;
            }
        });

        txtAmount.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if(((EditText) v).getId() == txtAmount.getId() && hasFocus) {
                    commentWrapper.setVisibility(View.INVISIBLE);
                }
            }
        });

        getCompanyValueList();
        view.setOnClickListener(null);
        return view;
    }

    @Override
    public void onClick(View arg0) {
    }

    @Override
    public void onResume()
    {
        listView.setVisibility(View.INVISIBLE);
        userAvatarImg.setVisibility(View.INVISIBLE);
        txtUserName.setText("", EditText.BufferType.EDITABLE);
        txtComment.setText("", EditText.BufferType.EDITABLE);
        txtAmount.setText("", EditText.BufferType.EDITABLE);
        choosedUserId = null;
        userList= new JSONArray();
        comapnySpinner.setSelection(0);
        super.onResume();
    }
    /** A callback method, which is executed when the activity is recreated
     * ( eg :  Configuration changes : portrait -> landscape )
     */

    public void getUserList(String searchKey) {
        InputMethodManager inputMethodManager = (InputMethodManager)  MainActivity.instance.getSystemService(Activity.INPUT_METHOD_SERVICE);
        inputMethodManager.hideSoftInputFromWindow(MainActivity.instance.getCurrentFocus().getWindowToken(), 0);
        MotivosityAPI api =  new MotivosityAPI(MainActivity.instance);
        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                userList = (JSONArray) obj;

                if (userList.length() > 0) {
                    adapter = new UserListAdapter(view.getContext(), userList);
                    listView.setAdapter(adapter);
                    listView.setVisibility(View.VISIBLE);

                    listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                        @Override
                        public void onItemClick(AdapterView<?> adapter, View v, int position, long id) {
                            try {
                                JSONObject data = (JSONObject) userList.get(position);

                                String itemValue = data.getString("fullName");
                                String userAvatar = data.getString("avatarUrl");
                                choosedUserId = data.getString("id");
                                choosedUserName = itemValue;

                                userAvatarImg.setVisibility(View.VISIBLE);
                                Picasso.with(view.getContext()).load(MainActivity.getUrl(userAvatar)).into(userAvatarImg);
                                txtUserName.setText(itemValue, EditText.BufferType.EDITABLE);
                                listView.setVisibility(View.INVISIBLE);
                                InputMethodManager inputMethodManager = (InputMethodManager)  MainActivity.instance.getSystemService(Activity.INPUT_METHOD_SERVICE);
                                inputMethodManager.hideSoftInputFromWindow(MainActivity.instance.getCurrentFocus().getWindowToken(), 0);
                                // Show Alert
                            } catch (JSONException e) {
                                Toast.makeText(view.getContext(),
                                        "Some Error occured.", Toast.LENGTH_LONG)
                                        .show();
                            }

                        }


                    });
                } else {
                    Toast.makeText(view.getContext(), "There is no user data...", Toast.LENGTH_LONG).show();
                    listView.setVisibility(View.INVISIBLE);
                    userAvatarImg.setVisibility(View.INVISIBLE);
                }
            }
        });
        api.setErrorCallback(new RestErrorCallback() {
            @Override
            public void error(String data) {
                String message;
                // try to read the JSON Object. If it fails, just show the data.
                try {
                    JSONObject obj = new JSONObject(data);
                    message = obj.getString("message");
                } catch (JSONException e) {
                    e.printStackTrace();
                    message = data;
                }

                Toast.makeText(view.getContext(), message, Toast.LENGTH_LONG).show();
            }
        });
        api.setLoadingMessage("Searching user list data...");
        api.searchUsers(searchKey);

    }

    public void SaveAppreciation(String companyId, String amount, String comment) {
        MotivosityAPI api =  new MotivosityAPI(MainActivity.instance);
        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                try {
                    JSONObject data = (JSONObject) obj;
                    JSONObject result = data.getJSONObject("growl");
                    if (result.has("title")) {
                        choosedUserId = "";
                        txtAmount.setText("", EditText.BufferType.EDITABLE);
                        txtComment.setText("", EditText.BufferType.EDITABLE);
                        getUserCash();

                    } else {
                        Toast.makeText(view.getContext(), "There is no user data...", Toast.LENGTH_LONG).show();
                        listView.setVisibility(View.INVISIBLE);
                        userAvatarImg.setVisibility(View.INVISIBLE);
                    }
                } catch (JSONException e) {
                }
            }
        });
        api.setErrorCallback(new RestErrorCallback() {
            @Override
            public void error(String data) {
                String message;
                // try to read the JSON Object. If it fails, just show the data.
                try {
                    JSONObject obj = new JSONObject(data);
                    message = obj.getString("message");
                } catch (JSONException e) {
                    e.printStackTrace();
                    message = data;
                }

                Toast.makeText(view.getContext(), message, Toast.LENGTH_LONG).show();
            }
        });
        if(choosedUserId==null || choosedUserId.isEmpty()) {
            Toast.makeText(view.getContext(), "Please choose user.", Toast.LENGTH_LONG).show();
        } else {
            api.setLoadingMessage("Posting data...");
            api.saveAppreciation(choosedUserId, comment, companyId, amount);
        }
    }

    public void getCompanyValueList() {
        MotivosityAPI api =  new MotivosityAPI(MainActivity.instance);
        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                companyList = (JSONArray) obj;
                ArrayList<String> company=new ArrayList<String>();
                company.add("Select");
                if (companyList.length() > 0) {
                    for(int i = 0; i < companyList.length(); i++) {
                        try {
                            JSONObject data = (JSONObject) companyList.get(i);
                            company.add(data.getString("name"));
                        } catch (JSONException e) {
                        }
                    }
                    ArrayAdapter<String> adapter = new ArrayAdapter<String>(view.getContext(), R.drawable.spinner_item , company);
                    adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                    comapnySpinner.setAdapter(adapter);

                } else {
                    Toast.makeText(view.getContext(), "There is no company data...", Toast.LENGTH_LONG).show();
                }
            }
        });
        api.setErrorCallback(new RestErrorCallback() {
            @Override
            public void error(String data) {
                String message;
                // try to read the JSON Object. If it fails, just show the data.
                try {
                    JSONObject obj = new JSONObject(data);
                    message = obj.getString("message");
                } catch (JSONException e) {
                    e.printStackTrace();
                    message = data;
                }

                Toast.makeText(view.getContext(), message, Toast.LENGTH_LONG).show();
            }
        });
        api.setLoadingMessage("Loading company data...");
        api.companyList();
    }

    public void getUserCash() {
        MotivosityAPI api =  new MotivosityAPI(MainActivity.instance);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                try {
                    JSONObject data = new JSONObject(obj.toString());
                    if (data.has("cashGiving") && data.has("cashReceiving")) {
                        MainActivity.cashGiving = data.getString("cashGiving");
                        MainActivity.cashReceiving = data.getString("cashReceiving");
                        MainActivity.instance.mHomeFragment = null;
                        MainActivity.instance.changeTabIdx(0);
                    } else {
                        Toast.makeText(view.getContext(), data.getString("message"), Toast.LENGTH_LONG).show();
                    }
                } catch(JSONException e) {
                    e.printStackTrace();
                    Toast.makeText(view.getContext(), obj.toString(), Toast.LENGTH_LONG).show();
                }
            }
        });
        api.setErrorCallback(new RestErrorCallback() {
            @Override
            public void error(String data) {
                String message;
                // try to read the JSON Object. If it fails, just show the data.
                try {
                    JSONObject obj = new JSONObject(data);
                    message = obj.getString("message");
                } catch (JSONException e) {
                    e.printStackTrace();
                    message = data;
                }

                Toast.makeText(view.getContext(), message, Toast.LENGTH_LONG).show();
            }
        });
        api.setLoadingMessage("Loading user balance...");
        api.userCash("");
    }
}
