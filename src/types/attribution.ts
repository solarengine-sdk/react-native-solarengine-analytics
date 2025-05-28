/**
 * SolarEngine attribution information type definition
 * @see https://help.solar-engine.com/cn/docs/attrdetail
 */
export interface AttributionInfo {
  attribution_touch_type?: string; // Type of attribution touch point (e.g. 'click', 'impression')
  ry_touchpoint_ts?: string; // Attribution touch point timestamp (YYYY-MM-DD HH:mm:ss)
  install_time?: string; // Device activation time (YYYY-MM-DD HH:mm:ss)
  attribution_time?: string; // Attribution time
  turl_campaign_id?: string; // Tracking link ID
  turl_campaign_name?: string; // Tracking link name
  turl_id?: string; // Short link ID
  channel_id?: string; // Channel ID
  channel_name?: string; // Channel name
  attribution_type?: string; // UA (identifies new user acquisition)
  account_id?: string; // Channel promotion account ID
  adgroup_id?: string; // Channel promotion ad group ID
  adgroup_name?: string; // Channel promotion ad group name
  adplan_id?: string; // Channel promotion plan ID
  adplan_name?: string; // Channel promotion plan name
  adcreative_id?: string; // Channel promotion creative ID
  adcreative_name?: string; // Channel promotion creative name
  adcreative_type?: string; // Channel promotion creative type
  site_id?: string; // Sub-channel ID
  site_name?: string; // Sub-channel name
  ad_type?: string; // Channel promotion ad type
  placement_id?: string; // Channel promotion placement ID
  conversion_id?: string; // Ad placement ID
  click_id?: string; // Click ID
  impression_id?: string; // Impression ID
  callback_id?: string; // Callback ID
  custom_params_1?: string; // Custom parameter 1
  custom_params_2?: string; // Custom parameter 2
  custom_params_3?: string; // Custom parameter 3
  custom_params_4?: string; // Custom parameter 4
  custom_params_5?: string; // Custom parameter 5
  client_custom_params_1?: string; // Client custom parameter 1
  client_custom_params_2?: string; // Client custom parameter 2
  client_custom_params_3?: string; // Client custom parameter 3
  client_custom_params_4?: string; // Client custom parameter 4
  client_custom_params_5?: string; // Client custom parameter 5
  re_data?: AttributionInfo; // Re-attribution data
}

export type AttributionCallback = (
  code: number,
  attribution?: AttributionInfo
) => void;
