package com.motivosity.android;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.manavo.rest.RestCallback;
import com.manavo.rest.RestErrorCallback;
import com.squareup.picasso.Picasso;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

/**
 * Created by sevenstar on 1/14/16.
 */
public class CommentActivity extends AppCompatActivity {
    public static String feedID = null;

    ImageView backBtn;
    ImageView itemAvatarImg;
    ImageView itemIconImg;
    RelativeLayout itemIconWrapper;
    TextView itemName;
    TextView itemDate;
    TextView itemTitle;
    TextView itemFeed;
    TextView likesText;
    TextView likesLink;
    ListView commentList;
    JSONArray commentData;

    JSONObject feedData;

    EditText itemComment;
    TextView itemPost;

    private View commentView;
    public CommentActivity commentInstance = null;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_comment);

        commentInstance = this;

        backBtn = (ImageView) findViewById(R.id.backBtn);
        itemAvatarImg = (ImageView) findViewById(R.id.itemAvatarImg);
        itemIconImg = (ImageView) findViewById(R.id.itemIcon);
        itemName = (TextView) findViewById(R.id.itemName);
        itemDate = (TextView) findViewById(R.id.itemDate);
        itemTitle = (TextView) findViewById(R.id.itemTitle);
        itemFeed = (TextView) findViewById(R.id.itemFeed);
        itemIconWrapper = (RelativeLayout) findViewById(R.id.itemIconWrapper);
        likesText = (TextView) findViewById(R.id.likesText);
        likesLink = (TextView) findViewById(R.id.likesLink);
        commentList = (ListView) findViewById(R.id.commentList);

        itemComment = (EditText) findViewById(R.id.itemComment);
        itemPost = (TextView) findViewById(R.id.itemPost);

        GetComment();
        itemPost.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                commentView = view;
                String comment = itemComment.getText().toString();
                if (comment.isEmpty()) {
                    Toast.makeText(view.getContext(), "Please type your comment...", Toast.LENGTH_LONG).show();
                } else {
                    AddComment(comment);
                }
            }
        });

        likesLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                likeFeed();
            }
        });

        backBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onBackPressed();
            }
        });

        MainActivity.instance.mHomeFragment.fromComment = true;
    }

    @Override
    public void onBackPressed()
    {
        // code here to show dialog
        super.onBackPressed();  // optional depending on your needs
    }

    public void AddComment(String comment) {
        InputMethodManager inputMethodManager = (InputMethodManager)  commentInstance.getSystemService(Activity.INPUT_METHOD_SERVICE);
        inputMethodManager.hideSoftInputFromWindow(commentInstance.getCurrentFocus().getWindowToken(), 0);
        MotivosityAPI api = new MotivosityAPI(commentInstance);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                GetComment();
                itemComment.setText("", EditText.BufferType.EDITABLE);
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
            }
        });
        api.setLoadingMessage("Posting comment...");
        api.postComment(comment, feedID);
    }

    public void GetComment() {
        MotivosityAPI api = new MotivosityAPI(commentInstance);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                feedData = (JSONObject) obj;
                try {
                    JSONObject subject = feedData.getJSONObject("subject");
                    itemTitle.setText(feedData.getString("title"));
                    itemDate.setText(feedData.getString("readableDate"));
                    itemName.setText(subject.getString("fullName"));
                    itemFeed.setText(feedData.getString("customAppreciationFeedTitle"));
                    likesLink.setText("Like");

                    itemIconWrapper.setBackgroundResource(R.drawable.home_icon_image_design);
                    GradientDrawable drawable = (GradientDrawable) itemIconWrapper.getBackground();
                    drawable.setColor(Color.parseColor(feedData.getString("feedIconColor")));
                    itemIconImg.setBackgroundColor(Color.parseColor(feedData.getString("feedIconColor")));
                    switch (feedData.getString("feedIconClass")) {
                        case "icon-brain":
                            itemIconImg.setImageResource(R.drawable.icon_brain);
                            break;
                        case "icon-bubbles":
                            itemIconImg.setImageResource(R.drawable.icon_bubbles);
                            break;
                        case "icon-cake":
                            itemIconImg.setImageResource(R.drawable.icon_cake);
                            break;
                        case "icon-calendar":
                            itemIconImg.setImageResource(R.drawable.icon_calendar);
                            break;
                        case "icon-gift":
                            itemIconImg.setImageResource(R.drawable.icon_gift);
                            break;
                        case "icon-info-sign":
                            itemIconImg.setImageResource(R.drawable.icon_info_sign);
                            break;
                        case "icon-light":
                            itemIconImg.setImageResource(R.drawable.icon_light);
                            break;
                        case "icon-medal":
                            itemIconImg.setImageResource(R.drawable.icon_medal);
                            break;
                        case "icon-prime":
                            itemIconImg.setImageResource(R.drawable.icon_prime);
                            break;
                        case "icon-star":
                            itemIconImg.setImageResource(R.drawable.icon_star);
                            break;
                        case "icon-target":
                            itemIconImg.setImageResource(R.drawable.icon_target);
                            break;
                        case "icon-trophy":
                            itemIconImg.setImageResource(R.drawable.icon_trophy);
                            break;
                        default:
                            itemIconImg.setImageResource(R.drawable.icon_prime);
                            break;
                    }

                    String feedAvatar = subject.getString("avatarUrl");
                    Picasso.with(commentInstance).load(MainActivity.getUrl(feedAvatar)).into(itemAvatarImg);

                    commentData = feedData.getJSONArray("commentList");
                    if (commentData.length() > 0) {
                        CommentListAdapter adapter = new CommentListAdapter(commentInstance, commentData);
                        commentList.setAdapter(adapter);
                    }

                    JSONArray likesData = feedData.getJSONArray("likes");
                    if(likesData.length() > 0) {
                        JSONObject likes = (JSONObject) likesData.get(0);
                        likesText.setText(likes.getString("fullName") + " likes this.");
                    }

                }catch(JSONException e ) {}

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
            }
        });
        api.setLoadingMessage("Loading comments...");
        api.getOneFeedItem(feedID);
    }

    public void likeFeed() {
        MotivosityAPI api = new MotivosityAPI(commentInstance);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                JSONObject data = (JSONObject) obj;
                try {
                    JSONArray likesData = data.getJSONArray("likes");
                    if(likesData.length() > 0) {
                        JSONObject likes = (JSONObject) likesData.get(0);
                        likesText.setText(likes.getString("fullName")+" likes this.");
                    }
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
        api.like(feedID);
    }
}
