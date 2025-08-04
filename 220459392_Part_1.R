# Load relevant libraries
library(ggplot2)

# Given probability desnity function f(x)
my_pdf <- function(x) {
   0.5 * exp(-abs(x))
}

# Function to run Random Walk Metropolis (RWM) algorithm
rwm_algorithm <- function(N, x0, s) {

  results <- data.frame(Iteration = 1:N, xi_Values = NA)
  results$xi_Values[1] <- x0
  
  for(i in 2:N) {
    random_num <- rnorm(1, mean = results$xi_Values[i-1], sd = s)
    ratio <- my_pdf(random_num) / my_pdf(results$xi_Values[i-1])
    u <- runif(1)
    
    if (u < ratio) {
      results$xi_Values[i] <- random_num
    } else {
      results$xi_Values[i] <- results$xi_Values[i-1]
    }
  }
  return(results)
}


 ## PART A


# Set initial parameters
x0 <- 10
s <- 1
N <- 10000

# Store output into variable 'results' with 2 columns: 'Iteration' and 'xi_Values'
results <- rwm_algorithm(N, x0, s)


## PLOTTING

# Generate actual x and y values using the pdf f(x)
x_values_actual <- seq(-20, 20, length.out = 1000)
y_values_actual <- my_pdf(x_values_actual)

# Create a data frame for simulated values
simulated_df <- data.frame(
  x = results$xi_Values,
  y = NA,
  Source = rep('Simulated', N)
)

# Create a data frame for original PDF values
original_df <- data.frame(
  x = x_values_actual,
  y = y_values_actual,
  Source = rep('Actual PDF', length(x_values_actual))
)

# Combine both data frames into a single 'df' consisting of columns 'x', 'y' and 'Source'

# 'x' column contains 10000 rows of values generated from RWM algorithm followed by 1000 rows of sequential
# 'y' column contains 10000 rows of 'NA' followed by 1000 rows of values computed using pdf f(x)
# 'Source' column indicates where the values come from

df <- rbind(simulated_df, original_df)

# Using the combined data frame 'df', plot histogram, kernel density to visualise estimates of f(x)
# Along with the actual PDF graph of f(x) = (1/2)exp(-|x|) to visualise the quality of the estimate

ggplot(df, aes(x = x, y = y, color = Source)) +
  geom_histogram(data = df[df$Source == 'Simulated', ], aes(y = ..density..),
                 bins = 30, fill = 'lightblue', color = 'black', alpha = 0.5) +
  geom_line(data = df[df$Source == 'Actual PDF', ], aes(y = y, color = 'Actual PDF'), size = 1.5) +
  geom_density(data = df[df$Source == 'Simulated', ], aes(y = ..density.., color = 'Simulated'), size = 1, na.rm = TRUE) +
  labs(title = 'Histogram and Kernel Density Plot with Actual PDF Overlay', x = 'Sampled Values') +
  scale_x_continuous(limits = c(-10,10)) +
  scale_color_manual(values = c('Simulated' = 'red', 'Actual PDF' = 'blue'),
                     labels = c('Simulated' = 'Simulated Density', 'Actual PDF' = 'Actual PDF')) +
  theme_bw()

# Extract simulated values from the 'results' vector
simulated_values <- results

# Calculate Monte Carlo estimate of the mean
monte_carlo_mean <- mean(simulated_values$xi_Values)

# Calculate Monte Carlo estimate of the standard deviation
monte_carlo_sd <- sd(simulated_values$xi_Values)

# Print or use the calculated values as needed
print(paste("Monte Carlo Estimate of Mean:", monte_carlo_mean))
print(paste("Monte Carlo Estimate of Standard Deviation:", monte_carlo_sd))


## PART B
  
# Set parameters
N <- 2000
s <- 0.001
J <- 4  # Number of chains
s_values <- seq(0.001, 1, length.out = 100)
  
# Compute R hat given specified parameters

calc_r_hat <- function(N, s, J) {
  
  # Generate J sequences with different random initial values
  chain_results <- lapply(1:J, function(j) {
    x0 <- runif(J, -10, 10)  # Generate a random initial value between -10 and 10 for each chain
    results <- rwm_algorithm(N, x0, s)
  })
  
  # Function to compute sample mean (Mj) for a given chain j
  compute_Mj <- function(chain) {
    mean_chain <- mean(chain$xi_Values)
    return(mean_chain)
  }
  
  # Calculate Mj for each chain
  Mj <- sapply(chain_results, compute_Mj)
  

  
  # Calculate Vj for each chain using the correct sample mean
  Vj <- sapply(chain_results, function(chain) var(chain))
  
  # Calculate overall within-sample variance (W)
  W <- mean(Vj)
  
  # Calculate overall sample mean (M)
  M <- mean(Mj)
  
  # Calculate between-sample variance (B)
  B <- mean((Mj - M)^2)
  
  # Calculate R-hat value
  R_hat <- sqrt((B + W) / W)
  
  
  return(R_hat)
}

# Retrieve final R-hat value

result <- calc_r_hat(N = 2000, s = 0.001, J = 4)
print(result)

# Retrieve values of R-hat for each s value
results <- sapply(s_values, function(s_value) {
  calc_r_hat(N, s_value, J)
})

# Plot calculated values

ggplot(data.frame(s = s_values, R_hat = results), aes(x = s, y = R_hat)) +
  geom_line() +
  labs(title = "R-hat v.s s",
       x = "s Value",
       y = "R-hat Value") +
  theme_bw()
 

