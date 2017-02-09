package com.motivosity.android;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.support.annotation.IdRes;
import android.support.annotation.LayoutRes;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.SimpleAdapter;
import android.widget.TextView;

import com.squareup.picasso.Picasso;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by sevenstar on 1/2/16.
 */
public class UserListAdapter extends BaseAdapter implements AdapterView.OnItemClickListener{

    JSONArray   userList;
    Context context;
    LayoutInflater      mInflater;
    ImageView userAvatarImg;

    public UserListAdapter(Context context, JSONArray userList) {
        this.context = context;
        this.userList = userList;
    }
//    public UserListAdapter(Context context, JSONArray feedList) {
//        this.userList = feedList;
//        this.context = context;
//    }

    @Override
    public int getCount() {
        return userList.length();
    }

    @Override
    public Object getItem(int position) {
        try {
            return userList.get(position);
        } catch(JSONException e) {
            return null;
        }
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        mInflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        convertView = mInflater.inflate(R.layout.autocomplete_thanks_username, null);

        TextView lblUserName = (TextView)convertView.findViewById(R.id.user_name);
        userAvatarImg = (ImageView)convertView.findViewById(R.id.user_avatar);


        try {
            JSONObject data = (JSONObject) userList.get(position);

            lblUserName.setText(data.getString("fullName"));
            String userAvatar = data.getString("avatarUrl");
            Picasso.with(convertView.getContext()).load(MainActivity.getUrl(userAvatar)).into(userAvatarImg);

        } catch(JSONException e) {
            e.printStackTrace();
        }

        return convertView;
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

    }
}
