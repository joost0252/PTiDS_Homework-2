# exercise 2 - emails 
### Package and software installation
## R install
install.packages("blastula")
install.packages("sodium")
install.packages("keyring")
install.packages("imager")

### Loading required libraries
library(blastula)
library(keyring)
library(ggplot2)
library(glue)
library(imager)

## creation database 
Emails <- c('ptdshec@gmail.com','aleksandr.shemendyuk@unil.ch','edward.tandia@unil.ch',
'aminayasmine.mohammed@unil.ch','joostdijkstra1995@gmail.com','alistair.bisol@unil.ch',
'andrea.ferrazzo@unil.ch','arturo.garcialunabeltran@unil.ch','Bruno.DaSilvaFerreira@unil.ch',
'clarence.koehle@unil.ch')
First_name <- c('Samuel','Aleksandr','Edward','Amina', 'Joost','Alistair','Andrea', 'Arturo', 'Bruno', 'Clarence')
Last_name <- c('Orso','Shemendyuk','Tandia','Mohammed','Dijkstra','Bisol', 'Ferrazzo', 'Garcialunabeltran',
'DaSilvaFerreira', 'Koehle') 
Client_id <- c(1,2,3,4,5,6,7,8,9,10)
Nationality <- c('Swiss','Russian','Colombian','Moroccan','Dutch','French','Italian','Spanish','Brazilian',
'German')
Hobby <- c('Skiing','Football','Basketball','Swimming','Tennis','Soccer','Volleyball','Cycling','Running','Golf')
Age <- c(48,29,25,26,26,23,26,24,25,26)
Profession <- c('Professor','PHD Student','Student','Student','Student','Student','Student','Student','Student',
'Student')
Bank <- c('BCGE','UBS','UBS','UBS','Credit Suisse','BCV','BCN','BCV','PostFinance','Reiffeisen')
Civil_status <- c('Married','Widow','Single','Single','Widow','Married','Married','Single','Single','Single')
Wealth <- c(100000,30000,80000,44776,100000,50000,25000,30300,10000,18740)
Gender <- c('male','male','male','female','male','male','female','male','male','female')
df <- data.frame(Emails,Client_id,First_name,Last_name,Gender,Nationality,Hobby,Age,Profession,Bank,Civil_status,Wealth)

# fusion first_name and last_name
df$Full_name <- paste(df$First_name, df$Last_name, sep = " ")

#load a premade dataset for ggplot
globus_data <- mtcars
colnames(globus_data)<-c('Calls','Data','Duration in sec','Costs')
globus_data # data are fake regarding this exact exercise

## ggplot wealth barplot with distinct colors
plot2 <-ggplot(
    data = globus_data,
    aes(x = Calls, y = Costs))+
  geom_point()+
  theme(
    axis.text.x = element_blank(),
    plot.title = element_text(size = 10))

plot_html <-
  add_ggplot(plot_object = plot2)

## Email customization

##creatation of reactive text  function
reactive_func <- function (full_name_id) {
        if (full_name_id[,8]>= 25 && full_name_id[,12] >= 50000) {
            proposition_f <- 'Last but not least, you are eligble for a 10% discount on your next purcharse.'
            }
        else if (full_name_id[,8] <= 28 && full_name_id[,12]<= 30000){
            proposition_f <-'Last but not least, you are eligble for a 5% discount on your next purcharse.'
            }
        else {
            proposition_f <- 'Last but not least, you are not eligble for any discount on your next purcharse.'
            }
    return(proposition_f)
     }

# define a given client_id_i (this would compose your iterator in a for loop to send to all client)

for (i in 1:nrow(df)){
    full_name_id <- df[i,] # i ici

    # define greeting
    greeting <-  ifelse(df[i, "Gender"] == "male", "Mr.", "Mrs.")
    
    # header
    img_f <- 'globus_img.png'
    globus<-add_image(file = img_f, width = 200)
    header_txt <- md(glue(
    globus,
    "Email by Globus team"
    ))

    # emails templates

    body_txt <- md(
        c(
            glue('Dear {greeting} {df[i,13]}'), #13 for full name col # i ici aussi
            '',
            glue('This mail is a reminder that you need to check the 
            monthly costs/calls record attached below. You can observe that your corsts decreased with 
            the increase of calls.'),
            plot_html,
            '',
            reactive_func(full_name_id),
            '',
            glue('Please let me know if you have any question.'),
            '',
            glue('Best regards, Gourp F')
            ))


    # footer
    date_time <- add_readable_time()
    footer_txt <- md(
    c(
        "Email sent on ", date_time, "."
    )
    )
    email_final <- compose_email(

    header = header_txt,

    body = blocks(
        block_text(body_txt),
        block_spacer()),

    footer = blocks(
        block_text(footer_txt),
        block_spacer(),
        block_social_links(
        social_link(
            service = "github",
            link = "https://github.com/ptds2022/class",
            variant = "color"
        )
        )
    )
    )
    email_final
}

# view mail html
email_final

# create identification smtp protocol (only to be run once)
#create_smtp_creds_key(
#   id = "outlook",
#   user = 'edward12-05@hotmail.com',
#   provider = 'outlook',overwrite = TRUE
#)

# extract email adress
email_adress <- df$Emails

# send email
email_final %>%
  smtp_send(
    from =  "edward12-05@hotmail.com",
    to = email_adress,
    subject = "Homework 2 exercise 2 - group F",
    credentials = creds_key('outlook')
  )

