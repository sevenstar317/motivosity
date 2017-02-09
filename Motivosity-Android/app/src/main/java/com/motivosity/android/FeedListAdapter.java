package com.motivosity.android;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.manavo.rest.RestCallback;
import com.manavo.rest.RestErrorCallback;
import com.squareup.picasso.Picasso;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.w3c.dom.Comment;

import java.util.ArrayList;

/**
 * Created by sevenstar on 1/2/16.
 */
public class FeedListAdapter extends BaseAdapter{

    JSONArray   feedList;

    Context context;
    LayoutInflater      mInflater;
    ImageView feedAvatarImg;
    ImageView feedIcon;
    RelativeLayout feedIconWrapper;
    TextView likeTxtView;
    TextView commentTxtView;
    TextView lblNumberOfLikes;
    TextView lblNumberOfComments;

    public FeedListAdapter(Context context, JSONArray feedList) {
        this.feedList = feedList;
        this.context = context;
    }

    @Override
    public int getCount() {
        return feedList.length();
    }

    @Override
    public Object getItem(int position) {
        try {
            return feedList.get(position);
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
        convertView = mInflater.inflate(R.layout.activity_home_feed_item, null);

        TextView lblDate = (TextView)convertView.findViewById(R.id.dateText);
        TextView lblTitle = (TextView)convertView.findViewById(R.id.titleText);
        lblNumberOfLikes = (TextView)convertView.findViewById(R.id.numberOfLikes);
        lblNumberOfComments = (TextView)convertView.findViewById(R.id.numberOfComments);
        feedAvatarImg = (ImageView)convertView.findViewById(R.id.feedAvatarImg);
        feedIcon = (ImageView)convertView.findViewById(R.id.feedIcon);
        feedIconWrapper = (RelativeLayout) convertView.findViewById(R.id.feedIconWrapper);
        TextView lblName = (TextView)convertView.findViewById(R.id.nameText);
        TextView feedTitle = (TextView)convertView.findViewById(R.id.feedTitle);
        likeTxtView = (TextView)convertView.findViewById(R.id.likeTextView);
        commentTxtView = (TextView)convertView.findViewById(R.id.commentTextView);
        commentTxtView.setTag(position);
        likeTxtView.setTag(position);

        likeTxtView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                try {
                    int position = (int) view.getTag();
                    JSONObject item = (JSONObject) getItem(position);
                    String id = item.getString("id");
                    likeFeed(id);
                } catch(JSONException e) {}
            }
        });

        commentTxtView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                try {
                    int position = (int) view.getTag();
                    JSONObject item = (JSONObject) getItem(position);
                    String id = item.getString("id");
                    CommentActivity.feedID = id;
                    Intent i = new Intent(context, CommentActivity.class);
                    MainActivity.instance.startActivity(i);
                }catch(JSONException e) {}
            }
        });

        try {
            JSONObject data = (JSONObject) feedList.get(position);
            JSONObject subject = data.getJSONObject("subject");
            lblNumberOfComments.setText(data.getInt("numberOfComments") + " comments");
            lblNumberOfLikes.setText(data.getInt("numberOfLikes") + " likes");
            lblDate.setText(data.getString("readableDate"));
            lblName.setText(subject.getString("fullName"));
            if(data.getString("feedType").toString().equals("APPR")) {
                lblTitle.setText(subject.getString("calculatedFirstName") + " received a thanks for " + data.getString("title") + " from " + data.getString("createdByName"));
            } else {
                lblTitle.setText(data.getString("title"));
            }
            try {
                feedTitle.setText(data.getString("note")); //note can be null now
            } catch (JSONException ne) {}
            String ed_text = feedTitle.getText().toString().trim();
            if(ed_text!=null && ed_text.length()> 0) {
                feedTitle.setVisibility(View.VISIBLE);
            } else {
                feedTitle.setVisibility(View.GONE);
            }

            feedIconWrapper.setBackgroundResource(R.drawable.home_icon_image_design);
            GradientDrawable drawable = (GradientDrawable) feedIconWrapper.getBackground();
            drawable.setColor(Color.parseColor(data.getString("feedIconColor")));
            feedIcon.setBackgroundColor(Color.parseColor(data.getString("feedIconColor")));
            switch(data.getString("feedIconClass")) {
                case "icon-brain": feedIcon.setImageResource(R.drawable.icon_brain); break;
                case "icon-bubbles": feedIcon.setImageResource(R.drawable.icon_bubbles); break;
                case "icon-cake": feedIcon.setImageResource(R.drawable.icon_cake); break;
                case "icon-calendar": feedIcon.setImageResource(R.drawable.icon_calendar); break;
                case "icon-gift": feedIcon.setImageResource(R.drawable.icon_gift); break;
                case "icon-info-sign": feedIcon.setImageResource(R.drawable.icon_info_sign); break;
                case "icon-light": feedIcon.setImageResource(R.drawable.icon_light); break;
                case "icon-medal": feedIcon.setImageResource(R.drawable.icon_medal); break;
                case "icon-prime": feedIcon.setImageResource(R.drawable.icon_prime); break;
                case "icon-star": feedIcon.setImageResource(R.drawable.icon_star); break;
                case "icon-target": feedIcon.setImageResource(R.drawable.icon_target); break;
                case "icon-trophy": feedIcon.setImageResource(R.drawable.icon_trophy); break;
                default: feedIcon.setImageResource(R.drawable.icon_prime); break;
            }

            String feedAvatar = subject.getString("avatarUrl");
            Picasso.with(convertView.getContext()).load(MainActivity.getUrl(feedAvatar)).into(feedAvatarImg);


        } catch(JSONException e) {
            e.printStackTrace();
        }

        return convertView;
    }

    public void likeFeed(String feedId) {
        MotivosityAPI api = new MotivosityAPI(MainActivity.instance);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                JSONObject data = (JSONObject) obj;
                try {
                    lblNumberOfLikes.setText(data.getInt("numberOfLikes") + " likes");
                    MainActivity.instance.mHomeFragment.page_num = 0;
                    MainActivity.instance.mHomeFragment.feedData = new JSONArray();
                    MainActivity.instance.mHomeFragment.getFeedList(MainActivity.instance.mHomeFragment.current_type, MainActivity.instance.mHomeFragment.page_num);
                } catch(JSONException e) {}
            }
        });
        api.setErrorCallback(new RestErrorCallback() {
            @Override
            public void error(String data) {
                String message = data;
            }
        });
        api.setLoadingMessage("Processing...");
        api.like(feedId);
    }
}
