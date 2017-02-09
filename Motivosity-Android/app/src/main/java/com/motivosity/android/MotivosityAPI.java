package com.motivosity.android;

import android.app.Activity;
import android.content.SharedPreferences;
import android.os.AsyncTask;

import com.manavo.rest.RestApi;

import org.json.JSONArray;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

/**
 * Created by sevenstar on 1/5/16.
 */
public class MotivosityAPI extends RestApi {
    public static String accessToken = null;
    public static String BaseHost = "www.motivosity.com";
    public static String StageBaseHost = "staging.motivosity.com";

    public MotivosityAPI(Activity activity) {
        super(activity);

        this.BASE_URL = MainActivity.ResourceStagingRootUrl+"api/v1/";
        this.urlSuffix = "";
        if(MainActivity.ResourceStagingRootUrl.contains("staging"))
            this.rest.setHost(StageBaseHost);
        else
            this.rest.setHost(BaseHost);
        this.rest.setPort(80);
        this.setUserAgent("motivosity");

        SharedPreferences sp1=activity.getSharedPreferences("Login",0);
        String token = sp1.getString("accessToken", null);
        if(token != null)
            accessToken = token;
    }

    public MotivosityAPI authorize(String email, String password) {
        // email acts as the username and token as the password of the basic auth
        this.rest.authorize(email, password);
        return this;
    }


    public void logIn(String email, String password) {
        this.addParameter("username", email);
        this.addParameter("password", password);
        this.post("auth/token");
    }

    public void passReset(String email) {
        this.addParameter("username", email);
        this.post("auth/password");
    }
    public void getFeed(String feedScopeLabel, Integer cPage) {
        String feedScope = "";
        switch(feedScopeLabel) {
            case "Company":
                feedScope = "CMPY";
                break;
            case "Department":
                feedScope = "DEPT";
                break;
            case "Extended Team":
                feedScope = "EXTM";
                break;
            case "Team Spirit":
                feedScope = "TEAM";
                break;
            default:
                feedScope = "EXTM";
                break;
        }
        this.get("feed?access_token="+accessToken+"&like=true&comment=true&scope="+feedScope+"&page="+cPage);
    }
    public void getOneFeedItem(String itemID) {
        this.get("feed/" + itemID + "?access_token=" + accessToken);
    }
    public void postComment(String comment, String feedId) {
        this.addParameter("commentText", comment);
        this.put("feed/"+feedId+"/comment?access_token="+accessToken);
    }
    public void like(String feedId) {
        this.put("feed/" + feedId + "/like?access_token=" + accessToken);
    }
    public void leaderboardList() {
        this.get("leaderboard/list?pageNo=0");
    }
    public void announcementList() {
        this.get("announcement/list?pageNo=0");
    }
    public void saveAnnouncement(String title, String note) {
        this.addParameter("title", title);
        this.addParameter("note", note);
        this.post("announcement/save");
    }
    public void saveAppreciation(String toUserID, String note, String companyValueID, String amount) {
        this.addParameter("note", note);
        this.addParameter("companyValueID", companyValueID);
        this.addParameter("amount", amount);
        this.put("user/" + toUserID + "/appreciation?access_token=" + accessToken);
    }
    public void companyList() {
        this.get("companyvalue?access_token="+accessToken);
    }
    public void searchUsers(String searchKey) {
        try {
            this.get("usertypeahead?access_token=" + accessToken + "&name=" + URLEncoder.encode(searchKey, "utf-8") + "&ignoreSelf=true");
        } catch(UnsupportedEncodingException e) {}
    }
    public void currentUser(String accessToken) {
        this.get("user?access_token="+accessToken);
    }
    public void userCash(String token) {
        if(token=="" || token.isEmpty() || token==null)
            this.get("usercash?access_token="+accessToken);
        else
            this.get("usercash?access_token="+token);
    }
    public void storeItems(String type) {
        this.get("store?access_token="+accessToken+"&type="+type);
    }
    public void purchase(JSONArray items) {
        this.postWithBody("store/purchase?access_token="+accessToken, items);
    }
} // end CallAPI
