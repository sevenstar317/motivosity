package com.motivosity.android;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.manavo.rest.RestCallback;
import com.manavo.rest.RestErrorCallback;
import com.squareup.picasso.Picasso;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by sevenstar on 1/19/16.
 */
public class OrderedListAdapter extends BaseAdapter {
    JSONArray orderList;

    Context context;

    LayoutInflater mInflater;
    ImageView btnCancel;
    ImageView itemImg;
    TextView itemTitle;
    TextView itemPrice;
    EditText itemQuantity;

    public OrderedListAdapter(Context context, JSONArray feedList) {
        this.orderList = feedList;
        this.context = context;
    }

    @Override
    public int getCount() {
        return orderList.length();
    }

    @Override
    public Object getItem(int position) {
        try {
            return orderList.get(position);
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
        convertView = mInflater.inflate(R.layout.activity_ordered_list, null);

        itemTitle = (TextView)convertView.findViewById(R.id.itemTitle);
        itemPrice = (TextView)convertView.findViewById(R.id.itemPrice);
        itemQuantity = (EditText)convertView.findViewById(R.id.itemQuantity);
        btnCancel = (ImageView)convertView.findViewById(R.id.btnCancel);
        itemImg = (ImageView)convertView.findViewById(R.id.itemImg);

        btnCancel.setTag(position);
        itemQuantity.setTag(position);

        itemQuantity.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                //You can identify which key pressed buy checking keyCode value with KeyEvent.KEYCODE_
                if (keyCode == KeyEvent.KEYCODE_ENTER || keyCode == KeyEvent.KEYCODE_NAVIGATE_NEXT) {
                    int position = (int) v.getTag();
                    try {
                        JSONObject data = (JSONObject) MainActivity.instance.orderedList.get(position);
                        if(Integer.parseInt(((EditText) v).getText().toString()) > 0)
                            data.put("currentQty", Integer.parseInt(((EditText) v).getText().toString()));
                        else
                            data.put("currentQty", 1);
                        MainActivity.instance.orderedList.put(position, data);
                        MainActivity.instance.storeShoppingCart(MainActivity.instance.orderedList);
                        MainActivity.instance.mStoreFragment.OpenShoppingCart();
                    } catch(JSONException e) {}

//                    InputMethodManager inputMethodManager = (InputMethodManager)  MainActivity.instance.getSystemService(Activity.INPUT_METHOD_SERVICE);
//                    inputMethodManager.hideSoftInputFromWindow(MainActivity.instance.getCurrentFocus().getWindowToken(), 0);
                }
                return false;
            }
        });

        btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                int position = (int) btnCancel.getTag();
                MainActivity.instance.orderedList.remove(position);
                MainActivity.instance.storeShoppingCart(MainActivity.instance.orderedList);
                MainActivity.instance.mStoreFragment.OpenShoppingCart();
            }
        });

        try {
            JSONObject data = (JSONObject) orderList.get(position);
            JSONObject item = (JSONObject) data.getJSONObject("item");
            itemQuantity.setText(data.getString("currentQty"), EditText.BufferType.EDITABLE);
            itemTitle.setText(item.getString("name"));
            float price = Float.parseFloat(item.getString("price"));
            if(data.getInt("userRedeemPrice") > 0)
                price = Float.parseFloat(data.getString("userRedeemPrice"));

            itemPrice.setText("$" + String.format("%.2f", price));
            String imageUrl = item.getString("imageUrl");
            if(item.getString("rewardType").equals("TANGO"))
                Picasso.with(convertView.getContext()).load(MainActivity.getStagingUrl(imageUrl)).into(itemImg);
            else
                Picasso.with(convertView.getContext()).load(MainActivity.getUrl(imageUrl)).into(itemImg);


        } catch(JSONException e) {
            e.printStackTrace();
        }

        return convertView;
    }
}
