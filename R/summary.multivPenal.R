#' summary of parameter estimates of a multivariate frailty model.
#' 
#' This function returns hazard ratio (HR) and its confidence intervals.
#' 
#' 
#' @usage \method{summary}{multivPenal}(object, level = 0.95, len = 6, d = 2, lab
#' = "hr", ...)
#' @param object output from a call to multivPenal for joint multivariate
#' models
#' @param level significance level of confidence interval. Default is 95\%.
#' @param d the desired number of digits after the decimal point. Default of 6
#' digits is used.
#' @param len the total field width. Default is 6.
#' @param lab label of printed results.
#' @param \dots other unused arguments.
#' @return Prints HR and its confidence intervals for each covariate.
#' Confidence level is allowed (level argument)
#' @seealso \code{\link{multivPenal}}
#' @keywords methods multiv
##' @export
"summary.multivPenal"<-
 function(object,level=.95, len=6, d=2, lab="hr", ...)
    {
        x <- object
        if (!inherits(x, "multivPenal")) 
         stop("Object must be of class 'multivPenal'")
      
        z<-abs(qnorm((1-level)/2))
        co <- x$coef
        se <- sqrt(diag(x$varH))[-c(1:2)]
        or <- exp(co)
        li <- exp(co-z * se)
        ls <- exp(co+z * se)
        r <- cbind(or, li, ls)

        dimnames(r) <- list(names(co), c(lab, paste(level*100,"%",sep=""), "C.I."))
      
        n<-r
   
        dd <- dim(n)
        n[n > 999.99] <- Inf
        a <- formatC(n, d, len,format="f")

        dim(a) <- dd
        if(length(dd) == 1){
          dd<-c(1,dd)
          dim(a)<-dd
          lab<-" "
          }
        else
          lab <- dimnames(n)[[1]]
      
        mx <- max(nchar(lab)) + 1

        cat("Recurrences:\n")
        cat("------------- \n")
        cat(paste(rep(" ",mx),collapse=""),paste("   ",dimnames(n)[[2]]),"\n")
        for(i in 1:x$nvar[1]) 
         {
          lab[i] <- paste(c(rep(" ", mx - nchar(lab[i])), lab[i]),collapse = "")
          cat(lab[i], a[i, 1], "(", a[i, 2], "-", a[i, 3], ") \n")
        }


        cat("\n") 
        cat("Terminal event:\n")
        cat("--------------- \n")
        cat(paste(rep(" ",mx),collapse=""),paste("   ",dimnames(n)[[2]]),"\n")
        for(i in (x$nvar[1]+1):(x$nvar[1]+x$nvar[2])) 
         {
          lab[i] <- paste(c(rep(" ", mx - nchar(lab[i])), lab[i]),collapse = "")
          cat(lab[i], a[i, 1], "(", a[i, 2], "-", a[i, 3], ") \n")
        }
        cat("\n") 
        cat("Recurrences 2:\n")
        cat("------------- \n")
        cat(paste(rep(" ",mx),collapse=""),paste("   ",dimnames(n)[[2]]),"\n")
        for(i in (x$nvar[1]+x$nvar[2]+1):dd[1]) 
         {
          lab[i] <- paste(c(rep(" ", mx - nchar(lab[i])), lab[i]),collapse = "")
          cat(lab[i], a[i, 1], "(", a[i, 2], "-", a[i, 3], ") \n")
        }

  }


