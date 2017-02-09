package com.motivosity.android;

import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
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

import com.squareup.picasso.Picasso;

public class MoreFragment extends Fragment  implements OnClickListener{

    public static String TAG = "More_Fragment";

    ImageView avatarImg;
    ImageView logoutIcon;
    TextView fullName, logoutLabel;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View v = inflater.inflate(R.layout.fragment_more, container, false);

        avatarImg = (ImageView) v.findViewById(R.id.more_avartImg);
        fullName = (TextView) v.findViewById(R.id.more_fullName);

        logoutIcon = (ImageView) v.findViewById(R.id.more_logoutImg);
        logoutLabel = (TextView) v.findViewById(R.id.more_logoutLbl);

        logoutIcon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                LogOut(view);

            }
        });

        logoutLabel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                LogOut(view);
            }
        });



        Picasso.with(v.getContext()).load(MainActivity.getUrl(MainActivity.userAvatarUrl)).into(avatarImg);
        fullName.setText(MainActivity.userFullName);

        logoutIcon.setBackgroundResource(R.drawable.home_icon_image_design);
        GradientDrawable drawable = (GradientDrawable) logoutIcon.getBackground();
        drawable.setColor(Color.parseColor("#ff7152"));
        logoutIcon.setImageResource(R.drawable.ic_logout);

        v.setOnClickListener(null);
        return v;
    }

    @Override
    public void onClick(View arg0) {
    }

    public void LogOut(View view) {
        MainActivity.instance.updateLogoutCredential();

        Intent i = new Intent(view.getContext(), LoginActivity.class);
        startActivity(i);
    }
}
