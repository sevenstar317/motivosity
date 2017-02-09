package com.motivosity.android;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.text.InputType;
import android.text.TextUtils;
import android.view.Gravity;
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

public class StoreFragment extends Fragment  implements OnClickListener{

    public static String TAG = "Store_Fragment";
    JSONArray digitalItems, charityItems, localItems;

    TextView orderedItemsCount;
    TextView btnCheckOut;
    TextView btnClearCart;
    ImageView imgCart;
    RelativeLayout layoutShoppingCart;
    public static ListView orderedListView;
    TextView txtEmpty;
    TextView txtTotalAmount;
    TextView lblDigital;
    TextView lblLocal;
    TextView lblCause;

    View view;

    private int confirmPrice;
    private int position;
    private JSONObject selectedItem;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        view = inflater.inflate(R.layout.fragment_store, container, false);
        getDigitalStore();

        orderedItemsCount = (TextView) view.findViewById(R.id.orderedItemsCount);
        btnCheckOut = (TextView) view.findViewById(R.id.btnCheckOut);
        btnClearCart = (TextView) view.findViewById(R.id.btnClearCart);
        txtTotalAmount = (TextView) view.findViewById(R.id.txtTotalAmount);
        imgCart = (ImageView) view.findViewById(R.id.imgCart);
        txtEmpty = (TextView) view.findViewById(R.id.emptyCartText);
        lblDigital = (TextView) view.findViewById(R.id.lblDigitalGifts);
        lblLocal = (TextView) view.findViewById(R.id.lblLocalGifts);
        lblCause = (TextView) view.findViewById(R.id.lblForCause);
        orderedListView = (ListView) view.findViewById(R.id.orderedListView);

        layoutShoppingCart = (RelativeLayout) view.findViewById(R.id.ShoppingCart);
        layoutShoppingCart.setVisibility(View.INVISIBLE);

        orderedItemsCount.setText(MainActivity.orderedList.length()+" items");

        orderedItemsCount.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                OpenShoppingCart();
            }
        });

        txtEmpty.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                OpenShoppingCart();
            }
        });

        btnCheckOut.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(MainActivity.orderedList.length()>0)
                    PurchaseOrderedList();
                else
                    Toast.makeText(view.getContext(), "Cart is Empty!", Toast.LENGTH_LONG).show();
            }
        });

        btnClearCart.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ClearCart();
            }
        });

        TextView companyStore = (TextView) view.findViewById(R.id.textView9);
        companyStore.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                layoutShoppingCart.setVisibility(View.INVISIBLE);
            }
        });
        TextView txtView13 = (TextView) view.findViewById(R.id.lblDigitalGifts);
        txtView13.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                layoutShoppingCart.setVisibility(View.INVISIBLE);
            }
        });
        TextView txtView14 = (TextView) view.findViewById(R.id.lblLocalGifts);
        txtView14.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                layoutShoppingCart.setVisibility(View.INVISIBLE);
            }
        });
        TextView txtView15 = (TextView) view.findViewById(R.id.lblForCause);
        txtView15.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                layoutShoppingCart.setVisibility(View.INVISIBLE);
            }
        });

        ScrollView scrollView = (ScrollView) view.findViewById(R.id.scrollView);
        scrollView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                layoutShoppingCart.setVisibility(View.INVISIBLE);
            }
        });

        view.setOnClickListener(null);
        return view;
    }

    @Override
    public void onClick(View arg0) {

    }

    public void getDigitalStore() {
        MotivosityAPI api = new MotivosityAPI(MainActivity.instance);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                digitalItems = (JSONArray)obj;
                getCharityStore();
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
        api.setLoadingMessage("Loading digital store data...");
        api.storeItems("digital");
    }

    public void getCharityStore() {
        MotivosityAPI api = new MotivosityAPI(MainActivity.instance);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                charityItems = (JSONArray) obj;
                getLocalStore();
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
        api.setLoadingMessage("Loading charity store data...");
        api.storeItems("charity");
    }
    public void getLocalStore() {
        MotivosityAPI api = new MotivosityAPI(MainActivity.instance);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                localItems = (JSONArray) obj;

                LinearLayout digital_layout = (LinearLayout) view.findViewById(R.id.digital_container);
                LinearLayout local_layout = (LinearLayout) view.findViewById(R.id.local_container);
                LinearLayout cause_layout = (LinearLayout) view.findViewById(R.id.cause_container);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT);
                layoutParams.setMargins(20, 20, 20, 20);
                layoutParams.gravity = Gravity.CENTER;
                layoutParams.width = 300;

                for (int i = 0; i < digitalItems.length(); i++) {
                    JSONObject item;
                    try {
                        item = (JSONObject) digitalItems.get(i);

                        ImageView imageView = new ImageView(getActivity());
                        imageView.setBackgroundResource(R.drawable.thanks_textfield_back_design);
                        imageView.setPadding(3, 3, 3, 3);
                        TextView textView = new TextView(getActivity());//create textview dynamically
                        textView.setHeight(360);
                        textView.setWidth(500);
                        textView.setTextColor(Color.parseColor("#2B7298"));
                        textView.setTextSize(14);
                        textView.setMaxLines(1);
                        textView.setEllipsize(TextUtils.TruncateAt.END);
                        textView.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
                        textView.setTypeface(null, Typeface.BOLD);

                        textView.setGravity(Gravity.BOTTOM);
                        textView.setText(item.getString("name"));
                        //                    imageView.setOnClickListener(documentImageListener);
                        imageView.setLayoutParams(layoutParams);

                        RelativeLayout rl = new RelativeLayout(getActivity());
                        rl.setPadding(20, 20, 20, 0);
                        RelativeLayout.LayoutParams lp;
                        lp = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
                        lp.width = 500;
                        lp.height = 300;
//                        imageView.setBackgroundResource(R.drawable.thanks_textfield_back_design);
                        Picasso.with(view.getContext()).load(MainActivity.getStagingUrl(item.getString("imageUrl"))).into(imageView);
                        imageView.setLayoutParams(lp);
                        rl.setTag(i);

                        rl.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                layoutShoppingCart.setVisibility(View.INVISIBLE);
                                try {
                                    position = (int) view.getTag();
                                    selectedItem = (JSONObject) digitalItems.get(position);
                                    if (position == 0) {
                                        ConfirmWithOptionDialog();
                                    } else {
                                        ConfirmWithPriceDialog();
                                    }
                                } catch (JSONException e) {
                                }
                            }
                        });

                        rl.addView(imageView);//add imageview to relativelayout
                        rl.addView(textView);

                        digital_layout.addView(rl);
                    } catch (JSONException e) {
                    }
                }
                if (charityItems.length() > 0) {
                    for (int i = 0; i < charityItems.length(); i++) {
                        JSONObject item;
                        try {
                            item = (JSONObject) charityItems.get(i);

                            ImageView imageView = new ImageView(getActivity());
                            imageView.setBackgroundResource(R.drawable.thanks_textfield_back_design);
                            imageView.setPadding(3, 3, 3, 3);
                            TextView textView = new TextView(getActivity());//create textview dynamically
                            textView.setHeight(360);
                            textView.setWidth(500);
                            textView.setTextColor(Color.parseColor("#2B7298"));
                            textView.setTextSize(14);
                            textView.setMaxLines(1);
                            textView.setEllipsize(TextUtils.TruncateAt.END);
                            textView.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
                            textView.setTypeface(null, Typeface.BOLD);

                            textView.setGravity(Gravity.BOTTOM);
                            textView.setText(item.getString("name"));
                            //                    imageView.setOnClickListener(documentImageListener);
                            imageView.setLayoutParams(layoutParams);

                            RelativeLayout rl = new RelativeLayout(getActivity());
                            rl.setPadding(20, 20, 20, 0);
                            RelativeLayout.LayoutParams lp;
                            lp = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
                            lp.width = 500;
                            lp.height = 300;
                            //                        imageView.setBackgroundResource(R.drawable.thanks_textfield_back_design);
                            Picasso.with(view.getContext()).load(MainActivity.getUrl(item.getString("imageUrl"))).into(imageView);
                            imageView.setLayoutParams(lp);
                            rl.setTag(i);

                            rl.setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View view) {
                                    layoutShoppingCart.setVisibility(View.INVISIBLE);
                                    try {
                                        position = (int) view.getTag();
                                        selectedItem = (JSONObject) charityItems.get(position);
                                        ConfirmWithPriceDialog();
                                    } catch (JSONException e) {
                                    }
                                }
                            });

                            rl.addView(imageView);//add imageview to relativelayout
                            rl.addView(textView);

                            cause_layout.addView(rl);
                        } catch (JSONException e) {
                        }
                    }
                    lblCause.setVisibility(View.VISIBLE);
                } else {
                    lblCause.setVisibility(View.INVISIBLE);
                }

                if (localItems.length() > 0) {
                    for (int i = 0; i < localItems.length(); i++) {
                        JSONObject item;
                        try {
                            item = (JSONObject) localItems.get(i);

                            ImageView imageView = new ImageView(getActivity());
                            imageView.setBackgroundResource(R.drawable.thanks_textfield_back_design);
                            imageView.setPadding(3, 3, 3, 3);
                            TextView textView = new TextView(getActivity());//create textview dynamically
                            TextView textPriceView = new TextView(getActivity());//create textview dynamically
                            textPriceView.setTextColor(Color.parseColor("#5FCCED"));
                            textPriceView.setText("$" + item.getString("price"));
                            textPriceView.setTextSize(14);
                            textPriceView.setHeight(300);
                            textPriceView.setWidth(490);
                            textPriceView.setGravity(Gravity.BOTTOM);
                            textPriceView.setTextAlignment(View.TEXT_ALIGNMENT_VIEW_END);
                            textPriceView.setTypeface(null, Typeface.BOLD);

                            textView.setHeight(360);
                            textView.setWidth(500);
                            textView.setTextColor(Color.parseColor("#2B7298"));
                            textView.setTextSize(14);
                            textView.setMaxLines(1);
                            textView.setEllipsize(TextUtils.TruncateAt.END);
                            textView.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
                            textView.setTypeface(null, Typeface.BOLD);

                            textView.setGravity(Gravity.BOTTOM);
                            textView.setText(item.getString("name"));
                            //                    imageView.setOnClickListener(documentImageListener);
                            imageView.setLayoutParams(layoutParams);

                            RelativeLayout rl = new RelativeLayout(getActivity());
                            rl.setPadding(20, 20, 20, 0);
                            RelativeLayout.LayoutParams lp;
                            lp = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
                            lp.width = 500;
                            lp.height = 300;
                            //                        imageView.setBackgroundResource(R.drawable.thanks_textfield_back_design);
                            Picasso.with(view.getContext()).load(MainActivity.getUrl(item.getString("imageUrl"))).into(imageView);
                            imageView.setLayoutParams(lp);

                            rl.setTag(i);

                            rl.setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View view) {
                                    layoutShoppingCart.setVisibility(View.INVISIBLE);
                                    try {
                                        position = (int) view.getTag();
                                        selectedItem = (JSONObject) localItems.get(position);
                                        ConfirmWithDialog();
                                    } catch (JSONException e) {
                                    }
                                }
                            });

                            rl.addView(imageView);//add imageview to relativelayout
                            rl.addView(textView);
                            rl.addView(textPriceView);

                            local_layout.addView(rl);
                        } catch (JSONException e) {
                        }
                    }
                    lblLocal.setVisibility(View.VISIBLE);
                } else {
                    lblLocal.setVisibility(View.INVISIBLE);
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
        api.setLoadingMessage("Loading local store data...");
        api.storeItems("local");
    }

    public void ConfirmWithDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(view.getContext());
        builder.setTitle("Add to Cart?");

// Set up the buttons
        builder.setPositiveButton("Yes", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                AddProductToCart();
            }
        });
        builder.setNegativeButton("No", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });

        builder.show();
    }

    public void ConfirmWithPriceDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(view.getContext());
        builder.setTitle("Add to Cart");

        builder.setMessage("Please enter amount $");

// Set up the input
        final EditText input = new EditText(view.getContext());
// Specify the type of input expected; this, for example, sets the input as a password, and will mask the text
        input.setInputType(InputType.TYPE_CLASS_NUMBER);
        builder.setView(input);

// Set up the buttons
        builder.setPositiveButton("Add", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (input.getText().toString().isEmpty() || input.getText().toString() == null) {
                    dialog.cancel();
                } else {
                    try {
                        confirmPrice = Integer.parseInt(input.getText().toString());
                        double minPrice = selectedItem.getDouble("minPrice");
                        if (minPrice <= confirmPrice) {
                            AddProductToCart();
                        } else {
                            Toast.makeText(view.getContext(), "Minimum price for this item -$" + String.valueOf(minPrice), Toast.LENGTH_LONG).show();
                        }
                    } catch(JSONException e) {}
                }
            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.cancel();
            }
        });

        builder.show();
    }

    public void ConfirmWithOptionDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(view.getContext());

        builder.setTitle("Add to Cart?");

        builder.setItems(new CharSequence[]
                        {"$10", "$25", "$50", "No"},
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // The 'which' argument contains the index position
                        // of the selected item
                        switch (which) {
                            case 0:
                                confirmPrice = 10;
                                break;
                            case 1:
                                confirmPrice = 25;
                                break;
                            case 2:
                                confirmPrice = 50;
                                break;
                            case 3:
                                dialog.cancel();
                                break;
                        }
                        AddProductToCart();
                    }
                });

        builder.show();
    }
    public void AddProductToCart() {
        JSONObject item = new JSONObject();
        try {
            item.put("id", selectedItem.getString("id"));
            item.put("item", selectedItem);
            item.put("currentQty", 1);
            if(confirmPrice > 0)
                item.put("userRedeemPrice", confirmPrice);
            else
                item.put("userRedeemPrice", 0);
            MainActivity.instance.orderedList.put(item);
            MainActivity.instance.storeShoppingCart(MainActivity.instance.orderedList);
            orderedItemsCount.setText(MainActivity.orderedList.length() + " items");
            confirmPrice = 0;
        } catch(JSONException e) {}
    }

    public void OpenShoppingCart() {
        OrderedListAdapter adapter = new OrderedListAdapter(view.getContext(), MainActivity.instance.getOrderedList());
        orderedItemsCount.setText(MainActivity.orderedList.length() + " items");
        orderedListView.setAdapter(adapter);
        if(MainActivity.orderedList.length() >0 ) {
            txtEmpty.setVisibility(View.INVISIBLE);
            orderedListView.setVisibility(View.VISIBLE);

            txtTotalAmount.setText("Total: $" + String.format("%.2f", GetTotalAmount()));
        } else {
            txtEmpty.setVisibility(View.VISIBLE);
            orderedListView.setVisibility(View.INVISIBLE);
            txtTotalAmount.setText("Total: $0.0");
        }
        layoutShoppingCart.setVisibility(View.VISIBLE);
    }

    public void PurchaseOrderedList() {
        MotivosityAPI api = new MotivosityAPI(MainActivity.instance);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                layoutShoppingCart.setVisibility(View.INVISIBLE);
                ClearCart();
                getUserCash();
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
        api.setLoadingMessage("Purchasing ordered items...");
        JSONArray orderedItems = new JSONArray();
        for(int i = 0; i < MainActivity.instance.orderedList.length(); i++) {
            try {
                JSONObject item = (JSONObject) MainActivity.instance.orderedList.get(i);
                item.remove("item");
                orderedItems.put(item);
            } catch(JSONException e) {}
        }
        api.purchase(orderedItems);
    }

    public void getUserCash() {
        MotivosityAPI api = new MotivosityAPI(MainActivity.instance);

        api.setCallback(new RestCallback() {
            public void success(Object obj) {
                try {
                    JSONObject data = new JSONObject(obj.toString());
                    if (data.has("cashGiving") && data.has("cashReceiving")) {
                        MainActivity.cashGiving = data.getString("cashGiving");
                        MainActivity.cashReceiving = data.getString("cashReceiving");
                        MainActivity.instance.cashReceivingText.setText("$"+ data.getString("cashReceiving"));
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

    public void ClearCart() {
        MainActivity.orderedList = new JSONArray();
        MainActivity.storeShoppingCart(MainActivity.orderedList);
        orderedItemsCount.setText(MainActivity.orderedList.length() + " items");
        layoutShoppingCart.setVisibility(View.INVISIBLE);
    }

    public static float GetTotalAmount() {
        float totalAmount = 0;
        for(int i = 0; i < MainActivity.orderedList.length(); i++) {
            try {
                JSONObject data = (JSONObject) MainActivity.orderedList.get(i);
                JSONObject item = data.getJSONObject("item");
                int quantity = data.getInt("currentQty");
                int price = item.getInt("price");
                if(data.getInt("userRedeemPrice") > 0)
                    price = data.getInt("userRedeemPrice");
                totalAmount += quantity * price;
            }catch(JSONException e) {}
        }
        return totalAmount;
    }
}