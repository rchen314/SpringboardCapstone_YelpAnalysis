###########################################
# R commands to process the Yelp database #
###########################################

#############################################
# Part 1:  Setup and initial data wrangling #
#############################################

# Load library
library(dplyr)

# Read in csv files
reviews    <- read.csv("yelp_academic_dataset_review.csv",   header = FALSE)
users      <- read.csv("yelp_academic_dataset_user.csv",     header = FALSE)
businesses <- read.csv("yelp_academic_dataset_business.csv", header = FALSE)

# Add names to the fields
colnames(reviews)[1] = "user_id"
colnames(reviews)[2] = "business_id"
colnames(reviews)[3] = "stars"
colnames(users)[1] = "user_id"
colnames(users)[2] = "user_name"
colnames(businesses)[1] = "business_id"
colnames(businesses)[2] = "city"
colnames(businesses)[3] = "business_name"
colnames(businesses)[4] = "categories"
colnames(businesses)[5] = "review_count"
colnames(businesses)[6] = "avg_stars"

# Join the files
ru  <- inner_join(reviews, users)
rub <- inner_join(ru, businesses)

######################################################
# Part 2a:  Analysis of Method 1 -- Initial Analysis #
######################################################

# Add "is_indian" field for any review that has "Indian" in "categories"
rub$is_indian <- grepl("Indian", rub$categories) == TRUE

# Make a dataframe of just reviews of Indian restaurants
indian <- subset(rub, is_indian == TRUE)

# Generate a summary of # of reviews of that cuisine done by each reviewer
num_reviews_Indian <- indian %>% select(user_id, user_name, is_indian) %>%
  group_by(user_id) %>% 
  summarise(tot_rev = sum(is_indian))

# Print the table, show the total # of entries, and find the avg # of reviews per user
table(num_reviews_Indian$tot_rev)
count(num_reviews_Indian)
mean(num_reviews_Indian$tot_rev)

#################################################################
# Part 2b:  Analysis of Method 1 -- Extension to Other Cuisines #
#################################################################

rub$is_chinese <- grepl("Chinese", rub$categories) == TRUE
chinese <- subset(rub, is_chinese == TRUE)
num_reviews_Chinese <- chinese %>% select(user_id, user_name, is_chinese) %>%
  group_by(user_id) %>% 
  summarise(tot_rev = sum(is_chinese))
table(num_reviews_Chinese$tot_rev)
count(num_reviews_Chinese)
mean(num_reviews_Chinese$tot_rev)

rub$is_mexican <- grepl("Mexican", rub$categories) == TRUE
mexican <- subset(rub, is_mexican == TRUE)
num_reviews_Mexican <- mexican %>% select(user_id, user_name, is_mexican) %>%
  group_by(user_id) %>% 
  summarise(tot_rev = sum(is_mexican))
table(num_reviews_Mexican$tot_rev)
count(num_reviews_Mexican)
mean(num_reviews_Mexican$tot_rev)

rub$is_italian <- grepl("Italian", rub$categories) == TRUE
italian <- subset(rub, is_italian == TRUE)
num_reviews_Italian <- italian %>% select(user_id, user_name, is_italian) %>%
  group_by(user_id) %>% 
  summarise(tot_rev = sum(is_italian))
table(num_reviews_Italian$tot_rev)
count(num_reviews_Italian)
mean(num_reviews_Italian$tot_rev)

# For Japanese, look for "Japanese" or "Sushi"
rub$is_japanese <- (grepl("Japanese", rub$categories) == TRUE) | 
                   (grepl("Sushi",    rub$categories) == TRUE)
japanese <- subset(rub, is_japanese == TRUE)
num_reviews_Japanese <- japanese %>% select(user_id, user_name, is_japanese) %>%
  group_by(user_id) %>% 
  summarise(tot_rev = sum(is_japanese))
table(num_reviews_Japanese$tot_rev)
count(num_reviews_Japanese)
mean(num_reviews_Japanese$tot_rev)

rub$is_greek <- grepl("Greek", rub$categories) == TRUE
greek <- subset(rub, is_greek == TRUE)
num_reviews_Greek <- greek %>% select(user_id, user_name, is_greek) %>%
  group_by(user_id) %>% 
  summarise(tot_rev = sum(is_greek))
table(num_reviews_Greek$tot_rev)
count(num_reviews_Greek)
mean(num_reviews_Greek$tot_rev)

rub$is_french <- grepl("French", rub$categories) == TRUE
french <- subset(rub, is_french == TRUE)
num_reviews_French <- french %>% select(user_id, user_name, is_french) %>%
  group_by(user_id) %>% 
  summarise(tot_rev = sum(is_french))
table(num_reviews_French$tot_rev)
count(num_reviews_French)
mean(num_reviews_French$tot_rev)

rub$is_thai <- grepl("Thai", rub$categories) == TRUE
thai <- subset(rub, is_thai == TRUE)
num_reviews_Thai <- thai %>% select(user_id, user_name, is_thai) %>%
  group_by(user_id) %>% 
  summarise(tot_rev = sum(is_thai))
table(num_reviews_Thai$tot_rev)
count(num_reviews_Thai)
mean(num_reviews_Thai$tot_rev)

rub$is_spanish <- (grepl("Spanish", rub$categories) == TRUE) | 
                  (grepl("Tapas",   rub$categories) == TRUE)
spanish <- subset(rub, is_spanish == TRUE)
num_reviews_Spanish <- spanish %>% select(user_id, user_name, is_spanish) %>%
  group_by(user_id) %>% 
  summarise(tot_rev = sum(is_spanish))
table(num_reviews_Spanish$tot_rev)
count(num_reviews_Spanish)
mean(num_reviews_Spanish$tot_rev)

rub$is_mediterranean <- grepl("Mediterranean", rub$categories) == TRUE
mediterranean <- subset(rub, is_mediterranean == TRUE)
num_reviews_Mediterranean <- mediterranean %>% select(user_id, user_name, is_mediterranean) %>%
  group_by(user_id) %>% 
  summarise(tot_rev = sum(is_mediterranean))
table(num_reviews_Mediterranean$tot_rev)
count(num_reviews_Mediterranean)
mean(num_reviews_Mediterranean$tot_rev)

#####################################################################
# Part 2c:  Analysis of Method 1 -- Apply new weight and see effect #
#####################################################################

# Combine num_reviews information with original data frame of indian restaurant reviews
cin <- inner_join(indian, num_reviews_Indian)

# Generate "weighted_stars" for later calculation
cin$weighted_stars <- cin$stars * cin$tot_rev

# Use "summarise" to generate a new rating for each restaurant
new_rating_Indian <- cin %>% select(city, business_name, avg_stars, stars, 
                                    tot_rev, weighted_stars) %>%
  group_by(city, business_name, avg_stars) %>%
  summarise(cnt = n(),
            avg = sum(stars) / cnt,
            new = sum(weighted_stars) / sum(tot_rev),
            dif = new - avg)

# Print summary data of the effect this new rating has
summary(new_rating_Indian$dif)

# Limit to those with at least 5 ratings and redo summary
nri5 <- subset(new_rating_Indian, cnt > 5)
summary(nri5$dif)
                                        

################################################################
# Part 3:  Analysis of Method 2 -- Generate "immigrant" rating #
################################################################

# Read Indian names into a list
inames <- scan("indian_names.txt", what = character())

# Add field "reviewer_indian_name" to indian reviews if user name is in the list
indian$reviewer_indian_name <- indian$user_name %in% inames

# Generate "istars" for internal calculation later
indian$istars <- indian$stars * indian$reviewer_indian_name

# Find out # of reviewers with a uniquely Indian name
table(indian$reviewer_indian_name)
1274/(1274 + 11872)    # .096

# Generate new "immigrant" rating
avg_rating_Indian <- indian %>% select(business_id, business_name, city, stars, 
                                       avg_stars, reviewer_indian_name, 
                                       is_indian, istars) %>%
                                group_by(city, business_name, avg_stars) %>%
                                summarise(count = n(),
                                          nin = sum(reviewer_indian_name),
                                          pin = sum(reviewer_indian_name) / n(),
                                          avg = sum(stars) / count,
                                          ias = sum(istars) / nin,
                                          dif = ias - avg)

# Find out extent of effect of new rating
summary(avg_rating_Indian$dif)

# Limit to those restaurants with at least 5 "immigrant" reviews and look at effect again
ari5 <- subset (avg_rating_Indian, nin > 5)                                        
summary(ari5$dif)





