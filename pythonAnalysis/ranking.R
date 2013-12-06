library("bigmemory")
library("biganalytics")
library("bigtabulate")
library("bigalgebra")
library("RSQLite")
library("multicore")
library("ggplot2")
library("compiler")
library("Rmpfr")

FAVORT = 1
FOLLOW = 1
RTWEET = 8

setup_users <- function(con) {
    print("Establishing Users")
    query      <- dbSendQuery(con, "SELECT * FROM users")
    userresult <- fetch(query, n=-1)
    cleared    <- dbClearResult(query)
    size       <- dim(userresult)[1]
    users      <- c(userresult[,1])
    users
}

user_weights <- function(con) {
    print("Establishing Edge Weights")
    users   <- setup_users(con)
    size    <- length(users)
    weights <- c()

    get_weight <- function(con, user, i) {
        query   <- dbSendQuery(con, gsub("%1", user,
                         "SELECT favourites_count,
                                 followers_count FROM users
                          WHERE id=%1"))
        result  <- fetch(query, n=-1)
        cleared <- dbClearResult(query)
        weight  <- FAVORT * result[1,1] + FOLLOW * result[1,2]
        weight
    }
    lapply(1:size, function(x) weights <<- append(weights,
                                                  get_weight(con,
                                                             users[x],
                                                             x)))
    weights_data <- data.frame(user=users, weight=weights)
    weights_data
}

get_links <- function(con, users) {
    print("Establishing User Links")
    query   <- dbSendQuery(con, "SELECT id, followers
                                   FROM users
                                   WHERE followers!='[]'")
    result  <- fetch(query, n=-1)
    cleared <- dbClearResult(query)
    links   <- data.frame(from=c(), to=c())
    lapply(1:dim(result)[1], function(x)
                               links <<- rbind(links[1:dim(links)[1],],
                                               result[x,]))
}

create_matrix <- function(size){
    # Create our nxn file backed matrix
    rankings <- big.matrix(size, size, type="double",
                                      backingfile="rankings",
                                      descriptorfile="rankings.desc")
    rankings
}

fill_matrix <- function(con, users, links) {
    size     <- nrow(users)
    rankings <- create_matrix(size)
    print("Adding Retweet Edges")
    query    <- dbSendQuery(con, "SELECT * FROM retweets")
    result   <- fetch(query, n=-1)
    cleared  <- dbClearResult(query)
    print("    Replacing Data")
    mclapply(1:dim(result)[1], function(x) rankings <<- replace(rankings,
                                                                result,
                                                                users,
                                                                x))
    print("Adding Follower Edges")
    query    <- dbSendQuery(con, "SELECT id, followers
                                    FROM users
                                      WHERE followers!='[]'")
    result   <- fetch(query, n=-1)
    cleared  <- dbClearResult(query)
    mclapply(1:dim(result)[1], function(x) rankings <<- followers(rankings,
                                                                  result,
                                                                  users,
                                                                  x))
    print("Normalizing")
    mclapply(1:size, function(x) rankings <<- normalize(rankings,x))
    #print("Writing")
    #write.big.matrix(rankings, "output.txt")
    rankings
}

followers <- function(rankings, result, users, row) {
    row          <- result[row,]
    user         <- row[1,1]
    followers    <- strsplit(row[1,2], ", |[^0-9]")
    follow_count <- length(followers[[1]])

    get_link <- function(rankings, users, to, from) {
        i             <- which(users$user == from)
        j             <- which(users$user == to)
        weight        <- FOLLOW + users[i,2]
        rankings[i,j] <- rankings[i,j] + weight
        rankings
    }

    mclapply(1:follow_count, function(x)
                                 rankings <<- get_link(rankings,
                                                       users,
                                                       user,
                                                       followers[[1]][x]))
    rankings
}

replace <- function(rankings, result, users, row) {
    #  |T
    # -|-
    # F|
    row           <- result[row,]
    from          <- row[1,1]
    to            <- row[1,2]
    i             <- which(users$user == from)
    j             <- which(users$user == to)
    c             <- strtoi(row[1,3])
    weight        <- RTWEET * c + users[i,2]
    rankings[i,j] <- weight
    rankings
}

normalize <- function(rankings, x) {
    row          <- rankings[x,]
    total        <- sum(row)
    if (total == 0) {
        total <- 1
    }
    rankings[x,] <- row / total
    rankings
}

norm <- function(vec) {
    sqrt(sum(vec^2))
}

power_method <- function(rankings, A, iterations) {
    for (i in 1:iterations) {
        B <- rankings[,] %*% A
        A <- B / norm(B[,])
    }
    A
}

main <- function() {
    args       <- commandArgs(trailingOnly = TRUE)
    database   <- args[1]
    drv        <- dbDriver("SQLite")
    con        <- dbConnect(drv, dbname=database)

    if (is.na(args[1])) {
        print("Need to supply Operation")
        q()
    }
    print("Creating Matrices")
    users    <- user_weights(con)
    links    <- get_links(con, users)
    rankings <- fill_matrix(con, users, links)
    print("Creating Initial Vector")
    A        <- big.matrix(nrow(users), 1, type="double",
                                          backingfile="A",
                                          descriptorfile="A.desc")
    A[1,] <- 1
    A <- A[,] / mpfr(norm(A[,]), precBits=200)
    iterations  <- args[2]
    print("Running Power Method")
    eigenvector <- power_method(rankings, A, iterations)
    print(eigenvector)
    print("Done")
}

system.time(main())
