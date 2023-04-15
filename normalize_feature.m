function normalized_feature = normalize_feature(feature)

feature_notnan = feature(~isnan(feature));
baseline = mean(feature_notnan(1:14));
normalized_feature = feature./baseline;

end
