### Package and software installation
## R install
# install.packages("blastula")
# install.packages("sodium")
# install.packages("keyring")
# system install on Linux
# sudo apt-get install libsodium-dev
# sudo apt-get install -y libsecret-1-dev

### Loading required libraries
library(blastula)
library(keyring)
library(ggplot2)
library(glue)

### Creating a fake database of customer's data
df_client <- data.frame(
  client_id = c(1,2), 
  gender = c("male", "male"),
  student = c(0,1),
  first_name = c("Samuel", "Aleksandr"),
  last_name = c("Orso", "Shemendyuk"),
  dob = c("01/01/1990", "01/01/1995"),
  date_since_client = c("01/01/2021", "30/10/2020"),
  email_adress = c("ptdshec@gmail.com", "ptdshec@gmail.com")
)
# compute number of days per client
df_client$nbr_days_since_client <- difftime(Sys.Date(), as.Date(df_client[, "date_since_client"], format = "%d/%m/%Y"))
# create data of usage
lst_usage <- vector("list", nrow(df_client))
# fill up list
lambda_val <- c(30, 20)
set.seed(123)
for (client_i in seq(nrow(df_client))) {
  lst_usage[[client_i]] <- rpois(n = df_client[client_i, "nbr_days_since_client"], lambda = lambda_val[client_i])
}
str(lst_usage)

### Creating a personalized email 
# define a given client_id_i (this would compose your iterator in a for loop to send to all client)
client_id_i <- 1
# compose email elements
# html button widget
cta_button <-
  add_cta_button(
    url = "https://fiber.salt.ch/fr",
    text = "Access your account"
  )
img_path <- "salt_logo.png"
brand_img <- add_image(file = img_path, width = 200)
# header
header_text <- md(glue(
  brand_img,
  "Mock homework for the class Programming tools in data science - HEC Lausanne"
))
# create plot
df_usage <- data.frame(minutes = lst_usage[[client_id_i]])
boxplot_usage <- add_ggplot(ggplot(df_usage, aes(y = minutes)) +
                              geom_boxplot(color = "black", fill = "grey80") +
                              theme(
                                axis.text.x = element_blank(),
                                plot.title = element_text(size = 10),
                                plot.margin = unit(c(0, 0, 0, 0), "cm")
                              ) +
                              ggtitle("Distribution of minutes per day"),
                            width = 2.5, height = 2
)
# young special if born after 93 and higher mean thant 9
# adult special if born before 93 and higher mean than 15
# body text
# propositon
age_days <- difftime(Sys.Date(), as.Date(df_client[client_id_i, "dob"], format = "%d/%m/%Y"), units = "days")
age_year <- floor(as.numeric(age_days, units = "days") / 365)
mean_min_call <- mean(lst_usage[[client_id_i]])

if (age_year >= 30 && mean_min_call >= 15) {
  proposition <- "As you are 30 years old or more and have an average of 15 or more minutes of calls per day, we are pleased to offer you the possibility of the adult premium plan."
} else if (age_year < 30 && mean_min_call >= 9) {
  proposition <- "As you are less than 30 years old and have an average of 9 or more minutes of calls per day, we are pleased to offer you the possibility of the younth premium plan."
} else if (age_year < 30 && mean_min_call < 9) {
  proposition <- "As you are less than 30 years old, you could have benefited from a change of subscription if you used your phone more frequently. 
  Indeed, you can benefit from a youth premium plan as soon as you average at least 9 minutes of calls per day."
}

# student discount
student_discount <- ifelse(df_client[client_id_i, "student"] == 1,
                           "Additionaly, given your student status, we propose you a 10% discount on the plan subscription price.", ""
)

# define greeting
greeting <- ifelse(df_client[client_id_i, "gender"] == "male", "Mr.", "Mrs.")


body_text <- md(
  c(
    "# A special offer for you",
    glue("Dear {greeting}{df_client[client_id_i, 4 ]} {df_client[client_id_i, 5 ]},"),
    "",
    glue("We are very happy to count you among our customers since    {df_client[client_id_i, 7 ]}."),
    "",
    glue("We analyzed how often you use our services, specifically the number of minutes you spend on the phone per day. 
         Here is a boxplot showing your usage during your {length(lst_usage[[client_id_i]])} days of use."),
    
    boxplot_usage,
    
    proposition,
    "",
    student_discount
  ))

# footer
date_time <- add_readable_time()
footer_text <- md(
  c(
    "Email sent on ", date_time, "."
  )
)

# Include the button in the email
# message body by using it as part of
# a vector inside of `md()`
email <- compose_email(
  
  header = header_text,
  
  body = blocks(
    block_text(body_text),
    block_spacer(),
    block_text(cta_button)
  ),
  footer = blocks(
    block_text(footer_text),
    block_spacer(),
    block_social_links(
      social_link(
        service = "github",
        link = "https://github.com/ptds2022/",
        variant = "color"
      )
    )
  )
)

# Preview email  
email

# create identification smtp protocol (only to be run once)
# create_smtp_creds_key(
#   id = "introds_gmail",
#   user = "happydatasciencewithr@gmail.com",
#   provider = "gmail", overwrite = T
# )

# extract email adress
email_adress <- df_client$email_adress

# send email
email %>%
  smtp_send(
    from =  "happydatasciencewithr@gmail.com",
    to = email_adress,
    subject = "PTDS - Homework 2",
    credentials = creds_key(id = "introds_gmail")
  )