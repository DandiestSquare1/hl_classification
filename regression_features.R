### this has the features of the regression model that have not null coefficients
# The model selected (with an l1-l2 ratio of 0.9) tends to select few features.
# Check out the lasso paper. That would be done with a l1-l2 ratio of 1.
# So this is pretty close to the lasso. It's called elastic-net
# http://web.stanford.edu/~hastie/TALKS/enet_talk.pdf
# There is a youtube video also. Just look for glmnet - talk

# $`-1`
# (Intercept)       cond086       cond098       cond018       cond094       cond006       cond068       cond069 
# -5.7013876500  2.4677911971 -2.4602519125  1.7179289573  1.4163939884  1.3908874418  1.3036298510  1.2076935930 
# cond067       cond096       cond095       cond005       cond097       cond004       cond066       cond077 
# 1.1861353037  1.0212587786  0.8877232791 -0.8300910205  0.6105542917 -0.5973099749  0.5515791469 -0.4516599628 
# cond013       cond019       cond016       cond075       cond021       cond104       cond008       cond081 
# -0.3835667449 -0.3702950708 -0.3607707917 -0.2358580310 -0.2216582707 -0.1882819732  0.1846463668  0.1808996891 
# cond090       cond083       cond001       cond015       cond084       cond020       cond082       cond093 
# -0.1683825423 -0.1603192090  0.1387104323 -0.1367193168 -0.1162433382 -0.1140809571 -0.0699082123  0.0514592808 
# cond022       cond087       cond105       cond017       cond091       cond092       cond023       cond003 
# -0.0418742578  0.0299544907 -0.0265770891  0.0237566275  0.0228540920  0.0221651038  0.0186442440 -0.0082658526 
# cond048 
# -0.0004704893 
# 
# $`0`
# (Intercept)       cond097       cond085       cond099       cond087       cond088       cond081       cond080 
# 10.6595629832 -1.3016812185 -0.9890903073 -0.8460470537 -0.6517394721 -0.5337702897 -0.4422730433 -0.4174532992 
# cond073       cond100       cond071       cond079       cond072       cond070       cond101       cond078 
# -0.3946666441 -0.3831285081 -0.2816216087 -0.2575182385 -0.2324372254 -0.1824867098 -0.1634989937 -0.1496978106 
# cond096       cond012       cond059       cond104       cond009       cond103       cond056 
# -0.0768986167  0.0293791201 -0.0272014869  0.0249381506  0.0248750688  0.0037337940  0.0005137304 
# 
# $`1`
# (Intercept)      cond086      cond098      cond018      cond084      cond075      cond077      cond085 
# -4.958175333 -2.759567398  1.896519066 -1.671239089  1.385453061  1.383938542  1.164294889  1.108112461 
# cond006      cond082      cond005      cond083      cond004      cond013      cond014      cond074 
# -0.992354675  0.971682226  0.708453899  0.650256952  0.604178509  0.507840984  0.433013615  0.382994738 
# cond076      cond069      cond019      cond016      cond067      cond020      cond068      cond092 
# 0.371692809 -0.350333184  0.233948219  0.230873074 -0.225040485  0.179189063 -0.149181751 -0.134954117 
# cond073      cond003      cond091      cond089      cond008      cond015      cond100      cond021 
# 0.134735541  0.129564355 -0.123326491  0.101471817 -0.099316890  0.089845856  0.089324510  0.081996748 
# cond079      cond007      cond010      cond105      cond080      cond093      cond001      cond094 
# 0.077556755 -0.061346417  0.050940240  0.048572193  0.039270692 -0.026995803 -0.023170893 -0.021998236 
# cond011      cond017      cond101      cond070      cond048 
# -0.014534928 -0.012366824  0.011730878  0.010944273  0.005512177 