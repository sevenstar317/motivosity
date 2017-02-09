package com.motivosity.android;

import android.content.SharedPreferences;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentTabHost;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONException;

import java.util.Timer;

public class MainActivity extends FragmentActivity implements View.OnClickListener {
    public static String ResourceRootUrl = "https://motivosity.s3.amazonaws.com/";
    public static String ResourceStagingRootUrl = "https://www.motivosity.com/";

    public static HomeFragment mHomeFragment = null;
    public static ThanksFragment mThanksFragment = null;
    public static StoreFragment mStoreFragment = null;
    public static MoreFragment mMoreFragment = null;
    public static String userAvatarUrl = "";
    public static String userFullName = "";
    public static String cashGiving = "";
    public static String cashReceiving = "";

    public static TextView cashGivingText;
    public static TextView cashReceivingText;

    public static JSONArray orderedList;

    private final int TAB_Home = 0;
    private final int TAB_Thanks = 1;
    private final int TAB_Store = 2;
    private final int TAB_More = 3;

    private Button btnHome = null;
    private Button btnThanks = null;
    private Button btnStore = null;
    private Button btnMore = null;

    private int mCurrentTabIdx = 0;

    public static MainActivity instance;

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        this.requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_main);

        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

        instance = this;

        btnHome = (Button)this.findViewById(R.id.btnHome);
        btnHome.setOnClickListener(this);

        btnThanks = (Button)this.findViewById(R.id.btnThanks);
        btnThanks.setOnClickListener(this);

        btnStore = (Button)this.findViewById(R.id.btnStore);
        btnStore.setOnClickListener(this);

        btnMore = (Button)this.findViewById(R.id.btnMore);
        btnMore.setOnClickListener(this);

        cashGivingText = (TextView) this.findViewById(R.id.cashGiving);
        cashReceivingText = (TextView) this.findViewById(R.id.cashReceiving);
        cashGivingText.setText('$'+cashGiving);
        cashReceivingText.setText('$'+cashReceiving);

        orderedList = getOrderedList();

        changeTabIdx(TAB_Home);
    }


    public void changeTabIdx(int newTabIdx)
    {
        TextView cashGivingText = (TextView) this.findViewById(R.id.cashGiving);
        TextView cashReceivingText = (TextView) this.findViewById(R.id.cashReceiving);
        cashGivingText.setText('$'+cashGiving);
        cashReceivingText.setText('$' + cashReceiving);

        if (newTabIdx >= TAB_More && mCurrentTabIdx == newTabIdx) {
            return;
        }

        mCurrentTabIdx = newTabIdx;
//        unselectAllTabButton();

        switch (mCurrentTabIdx) {
            case TAB_Home:
                if(mHomeFragment == null){
                    mHomeFragment = new HomeFragment();
                    addFragment(mHomeFragment, mHomeFragment.TAG);
                }else{
                    showFragment(mHomeFragment);
                }
                break;

            case TAB_Thanks:
                if(mThanksFragment == null){
                    mThanksFragment = new ThanksFragment();
                    addFragment(mThanksFragment, mThanksFragment.TAG);
                }else{
                    mThanksFragment.onResume();
                    showFragment(mThanksFragment);
                }
                break;

            case TAB_Store:
                if(mStoreFragment == null){
                    mStoreFragment = new StoreFragment();
                    addFragment(mStoreFragment, mStoreFragment.TAG);
                }else{
                    showFragment(mStoreFragment);
                }
                break;

            case TAB_More:
                if(mMoreFragment == null){
                    mMoreFragment = new MoreFragment();
                    addFragment(mMoreFragment, mMoreFragment.TAG);
                }else{
                    showFragment(mMoreFragment);
                }
                break;
        }
    }

    public void addFragment(Fragment newFragment, String tag) {

        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.add(R.id.fragmentRoot, newFragment);
        ft.addToBackStack(tag);
        ft.commit();
    }

    public void showFragment(Fragment selectedFragment) {

        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        if(mHomeFragment != null)
            ft.hide(mHomeFragment);
        if(mThanksFragment != null)
            ft.hide(mThanksFragment);
        if(mStoreFragment != null)
            ft.hide(mStoreFragment);
        if(mMoreFragment != null)
            ft.hide(mMoreFragment);
        ft.show(selectedFragment);
        ft.commit();
    }

    @Override
    public void onClick(View arg0)
    {
        switch(arg0.getId())
        {
            case R.id.btnHome:
                changeTabIdx(TAB_Home);
                break;
            case R.id.btnThanks:
                changeTabIdx(TAB_Thanks);
                break;
            case R.id.btnStore:
                changeTabIdx(TAB_Store);
                break;
            case R.id.btnMore:
                changeTabIdx(TAB_More);
                break;
        }
    }

    public static String getUrl(String url) {
        return ResourceRootUrl + url;
    }
    public static String getStagingUrl(String url) {
        return ResourceStagingRootUrl+ url;
    }

    public static void storeShoppingCart(JSONArray orderedList) {
        SharedPreferences sp=MainActivity.instance.getSharedPreferences("Motivosity_ShoppingCart", 0);
        SharedPreferences.Editor Ed=sp.edit();
        Ed.putString("ShoppingCart", orderedList.toString());
        Ed.commit();
    }

    public static void updateLogoutCredential() {
        SharedPreferences sp = MainActivity.instance.getSharedPreferences("Login", 0);
        SharedPreferences.Editor Ed = sp.edit();
        Ed.putString("accessToken", null);
        Ed.putString("username", null);
        Ed.putString("password", null);
        Ed.commit();
    }

    public static JSONArray getOrderedList() {
        SharedPreferences sp1=MainActivity.instance.getSharedPreferences("Motivosity_ShoppingCart",0);
        String shoppingCart = sp1.getString("ShoppingCart", null);
        JSONArray orderedList;

        if (shoppingCart == null || shoppingCart.isEmpty())
            orderedList = new JSONArray();
        else {
            try {
                orderedList = new JSONArray(shoppingCart);
            } catch(JSONException e) {
                return new JSONArray();
            }
        }

        return orderedList;
    }
}
