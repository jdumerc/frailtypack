##' Predict Method for the one-step Joint surrogate model for the evaluation of a 
##' canditate surrogate endpoint.
##' 
##' Predict the treatment effect on the true endpoint (\eqn{beta_T}), basing on the 
##' treatment effect observed on the the surrogate endpoint (\eqn{beta_S}).
##' 
##' Prediction is based on the formulas described in (Burzikwosky \emph{et al.}, 2006).
##' We do not consider the case of prediction which suppose estimation error on 
##' the estimate of the treatment effect on the surrogate endpoint in the new trial.
##' 
##' @aliases predict.jointSurroPenal 
##' @usage
##' 
##' \method{predict}{jointSurroPenal}(object, datapred = NULL, var.used = "error.meta", ...)
##' @param object An object inheriting from \code{jointSurroPenal} class
##' (output from calling \code{jointSurroPenal} function).
##' @param datapred Dataset to used for the prediction. If this argument is specified,
##' the data structure must be the same as the parameter \code{data} in the 
##' function \link{jointSurroPenal}. However, if observation on te true endpoint are
##' not available, columns timeT and \code{statusT} can be absent.
##' @param var.used This argument takes two values. The first one is \code{"error.meta"}
##' and indicates if the prediction error take into account
##' the estimation error of the estimates of the parameters. If the estimates 
##' are suppose knew or if the dataset includes a high number of trials with 
##' a high number of subject per trial, value \code{"No.error} can be used. 
##' The default is \code{"error.meta"}.
##' @param ... other unused arguments.
##' @return Return and display a dataframe including for each trial the observed 
##' treatment effect on the surrogate endpoint, the observed treatment effect on
##' the true endpoint (if available) and the predicted treatment effect on the 
##' true enpoint with the associated prediction intervalls.
##' @seealso \code{\link{jointSurroPenal}}
##' 
##' @author Casimir Ledoux Sofeu \email{casimir.sofeu@u-bordeaux.fr}, \email{scl.ledoux@gmail.com} and 
##' Virginie Rondeau \email{virginie.rondeau@inserm.fr}
##' 
##' @references 
##' Burzykowski T, Buyse M (2006). “Surrogate threshold effect: an alternative 
##' measure for meta-analytic surrogate endpoint validation.” Pharmaceutical 
##' Statistics, 5(3), 173–186.ISSN 1539-1612.
##' 
##' @keywords surrogate prediction
##' @export
##' @examples
##' 
##' 
##' \dontrun{
##' 
##' 
##' ###--- Joint surrogate model ---###
##' ###---evaluation of surrogate endpoints---###
##' 
##' data(dataOvarian)
##' joint.surro.ovar <- jointSurroPenal(data = dataOvarian, n.knots = 8, 
##'                 init.kappa = c(2000,1000), indicator.alpha = 0, nb.mc = 200, 
##'                 scale = 1/365)
##' 
##' # prediction of the treatment effects on the true endpoint in each trial of 
##' the dataOvarian dataset
##' # predict(joint.surro.ovar)
##' 
##' }
##' 
##' 
"predict.jointSurroPenal" <- function (object, datapred = NULL, var.used = "error.meta", ...)
{
  if (!inherits(object, "jointSurroPenal"))
    stop("object must be of class 'jointSurroPenal'")
  
  if(! var.used %in% c("error.meta","No.error"))
    stop("Argument 'var.used' must be specified to 'error.meta' or 'No.error' ")
  
  if(is.null(datapred)){ # we used the dataset from the model
    dataUse <- x$data
  }
  else{
    # ================ data checking=======================
      dataUse <- datapred
      # The initial followup time. The default value is 0
      dataUse$initTime <- 0 
      # dataset's names control
      varStatus=(c("initTime","timeS","statusS","trialID","patienID","trt") %in% names(data))
      if(F %in% varStatus){
        stop("Control the names of your variables. They must contain at leat 5 variables named: timeS, statusS, trialID, patienID and trt. seed the help on this function")
      }
      
      # traitement des donnees
      if(max(table(data$patienID)) > 1){
        stop("Control your dataset. You probably have a duplicate on individual (patienID variable)")
      }
      
      if(!is.numeric(data$timeS)|!is.numeric(data$trialID)){
        stop("The variables timeS, and trialID must be numeric") 
      }
      
      if(F %in% c(levels(as.factor(as.character(data$statusS))) %in% c(0,1),levels(as.factor(as.character(data$trt))) %in% c(0,1))){
        stop("The variables statusS, and trt must be coded 0 or 1")
      }
      if(T %in% c((data$timeS - data$initTime) <= 0)){
        stop("Controll the follow up times of your sujects. the is at leat one subjects with intTime > timeS ")
      }
    # ====================== end data checking ==============================
  }
  
  trial <- unique(dataUse$trialID)
  if(F %in% (c("timeT","statusT") %in% names(dataUse))){
    matrixPred <- data.frame(matrix(0, nrow = length(trial), ncol = 5))
    names(matrixPred) <- c("trialID","bata.S", "beta.T.i", "Inf.95.CI", "Sup.95.CI" )
    matrixPred$trialID <- trial
    for(i in 1:length(trial)){
      subdata <- dataUse[dataUse$trialID == trial[i],]
      matrixPred$beta.S[i] <- coxph(Surv(timeS, statusS) ~ trt, subdata)$coefficients
    }
  }
  else{
    matrixPred <- data.frame(matrix(0, nrow = length(trial), ncol = 6))
    names(matrixPred) <- c("trialID","bata.S", "beta.T", "beta.T.i", "Inf.95.CI", "Sup.95.CI" )
    matrixPred$trialID <- trial
    for(i in 1:length(trial)){
      subdata <- dataUse[dataUse$trialID == trial[i],]
      matrixPred$beta.S[i] <- coxph(Surv(timeS, statusS) ~ trt, subdata)$coefficients
      matrixPred$beta.T[i] <- coxph(Surv(timeT, statusT) ~ trt, subdata)$coefficients
    }
  }
  
  for(i in 1:length(trial)){
    beta  <- object$beta.t
    dab   <- object$Coefficients$Estimate[nrow(object$Coefficients)-4]
    daa   <- object$Coefficients$Estimate[nrow(object$Coefficients)-6]
    dbb   <- object$Coefficients$Estimate[nrow(object$Coefficients)-5]
    alpha <- object$beta.s
    alpha0 <- matrixPred$beta.S[i]
    x     <- t(matrix(c(1, -dab/daa),1,2))
    Vmu   <- matrix(c(),2,2)
    VD    <- matrix(c(),2,2)
    R2trial <- object$Coefficients$Estimate[nrow(object$Coefficients)-1] 
    matrixPred$beta.T.i[i] <- beta + (dab/daa) * (alpha0 - alpha)
    variance.inf <- dbb * (1 - R2trial) 
    variance.N <- t(x) %*% (Vmu %+% (((alpha0 - alpha)/daa)**2) %*% VD) %*% x
    + variance.inf
    
    if(var.used == "error.meta") 
      variance <- variance.N
    else 
      variance <- variance.inf
    
    matrixPred$Inf.95.CI[i] <- matrixPred$beta.T.i[i] - qnorm(1-alpha./2) * sqrt(variance)
    matrixPred$Sup.95.CI[i] <- matrixPred$beta.T.i[i] + qnorm(1-alpha./2) * sqrt(variance)
  }
  
  print(matrixPred)
  return(matrixPred)

}