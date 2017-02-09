package com.motivosity.android;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.squareup.picasso.Picasso;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by sevenstar on 1/14/16.
 */
public class CommentListAdapter extends BaseAdapter {
    JSONArray   commentList;

    Context context;
    LayoutInflater      mInflater;

    TextView commentText;
    TextView commentName;
    TextView commentDate;
    ImageView commentAvatar;

    public CommentListAdapter(Context context, JSONArray feedList) {
        this.commentList = feedList;
        this.context = context;
    }

    @Override
    public int getCount() {
        return commentList.length();
    }

    @Override
    public Object getItem(int position) {
        try {
            return commentList.get(position);
        } catch(JSONException e) {
            return null;
        }
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        mInflater = (LayoutInflater)context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        convertView = mInflater.inflate(R.layout.activity_comment_list, null);

        commentText = (TextView) convertView.findViewById(R.id.commentText);
        commentName = (TextView) convertView.findViewById(R.id.commentName);
        commentDate = (TextView) convertView.findViewById(R.id.commentDate);

        commentAvatar = (ImageView) convertView.findViewById(R.id.commentAvatar);

        try {
            JSONObject data = (JSONObject) commentList.get(position);
            JSONObject commentUser = (JSONObject) data.getJSONObject("user");
            commentText.setText(data.getString("commentText"));
            commentName.setText(commentUser.getString("fullName"));
            commentDate.setText(data.getString("readableCreatedDate"));

            Picasso.with(convertView.getContext()).load(MainActivity.getUrl(commentUser.getString("avatarUrl"))).into(commentAvatar);
        } catch(JSONException e) {}

        return convertView;
    }
}
