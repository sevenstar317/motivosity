package com.motivosity.android;

import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.*;

import com.manavo.rest.RestCallback;
import com.manavo.rest.RestErrorCallback;
import com.squareup.picasso.Picasso;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;

public class HomeFragment extends Fragment implements OnClickListener {

    public static String TAG = "Home_Fragment";
    public static Integer page_num = 0;
    public static String current_type;
    public static JSONArray feedData=new JSONArray();
    public static Boolean fromComment = false;
    String[] type;
    Boolean flag_loading=false;
    FeedListAdapter adapter;
    ListView listView;
    TextView companyValue;
    View view;

    Parcelable listViewState;

    ImageView avatarImg;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {



        view = inflater.inflate(R.layout.fragment_home, container, false);
        type = getResources().getStringArray(R.array.home_spinner);
        current_type = type[getFeedScope()];
        avatarImg = (ImageView) view.findViewById(R.id.avatarImg);
        listView = (ListView) view.findViewById(R.id.listView);
        companyValue = (TextView) view.findViewById(R.id.CompanyValue);

        listView.setOnScrollListener(new AbsListView.OnScrollListener() {

            public void onScrollStateChanged(AbsListView view, int scrollState) {


            }

            public void onScroll(AbsListView view, int firstVisibleItem,
                                 int visibleItemCount, int totalItemCount) {

                if(firstVisibleItem+visibleItemCount == totalItemCount && totalItemCount!=0)
                {
                    if (flag_loading == false && page_num>-1) {
                        flag_loading = true;
                        page_num += 1;
                        getFeedList(current_type, page_num);
                    }
                }
            }
        });

        Picasso.with(view.getContext()).load(MainActivity.getUrl(MainActivity.userAvatarUrl)).into(avatarImg);

        Spinner spinner = (Spinner)view.findViewById(R.id.home_spinner);
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(view.getContext(), R.array.home_spinner, R.layout.home_spinner_item);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinner.setAdapter(adapter);

        spinner.setSelection(getFeedScope());
        companyValue.setText(current_type);

        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parentView, View selectedItemView, int position, long id) {
                // your code here
                storeFeedScope(position);
                current_type = type[position];
                companyValue.setText(current_type);
                page_num = 0;
                feedData = new JSONArray();
                getFeedList(current_type, page_num);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parentView) {
                // your code here
            }

        });

        view.setOnClickListener(null);
        return view;
    }

    @Override
    public void onResume()
    {
        if(feedData.length() >0 && fromComment) {
            type = getResources().getStringArray(R.array.home_spinner);
            feedData = new JSONArray();
            current_type = type[getFeedScope()];
            fromComment = false;
            getFeedList(current_type, 0);
        }
        super.onResume();
    }

    public void getFeedList(String feedScope, Integer cPage) {
        MotivosityAPI api = new MotivosityAPI(MainActivity.instance);
        listViewState = listView.onSaveInstanceState();

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                flag_loading = false;
                JSONArray data = (JSONArray)obj;
                if(data.length() < 15) page_num = -1;
                try {
                    for (int i = 0; i < data.length(); i++)
                        feedData.put(data.get(i));
                } catch(JSONException e) { }
                if (feedData.length() > 0) {
                    adapter = new FeedListAdapter(view.getContext(), feedData);
                    listView.setAdapter(adapter);
                    listView.onRestoreInstanceState(listViewState);
                } else {
                    Toast.makeText(view.getContext(), "There is no feed data...", Toast.LENGTH_LONG).show();
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
        api.setLoadingMessage("Loading feed data...");
        api.getFeed(feedScope, cPage);
    }

    @Override
    public void onClick(View arg0) {
    }

    private void storeFeedScope(Integer feedScope) {
        SharedPreferences sp=MainActivity.instance.getSharedPreferences("Motivosity_FeedScope", 0);
        SharedPreferences.Editor Ed=sp.edit();
        Ed.putString("FeedScope", feedScope.toString());
        Ed.commit();
    }

    private Integer getFeedScope() {
        SharedPreferences sp1=MainActivity.instance.getSharedPreferences("Motivosity_FeedScope",0);
        String feedScope = sp1.getString("FeedScope", null);
        if(feedScope == null || feedScope.isEmpty())
            return 3;
        else
            return Integer.valueOf(feedScope);
    }

}