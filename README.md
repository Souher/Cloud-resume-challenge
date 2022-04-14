<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#blog">Blog</a>
      <ul>
        <li><a href="#HTML, CSS, S3">HTML, CSS, S3</a></li>
        <li><a href="#DNS, CloudFront, ACM">DNS, CloudFront, ACM</a></li>
        <li><a href="#DynamoDB, Lambda, API, JavaScript">DynamoDB, Lambda, API, JavaScript</a></li>
        <li><a href="#Infrastructure As Code, CI/CD, Testing, Locked TF State">Infrastructure As Code, CI/CD, Testing, Locked TF State</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project
This project was challenge set by [Forrest Brazeal](https://forrestbrazeal.com/). Details of the challenge can be found [here](https://cloudresumechallenge.dev/docs/the-challenge/aws/)

![Cloud Architecture](./CloudArchitecture.jpeg?raw=true "Cloud Architecture")

<p align="right">(<a href="#top">back to top</a>)</p>



### Built With

* [Amazon Web Services](https://aws.amazon.com/)
  * AWS products
    * S3
    * CloudFront
    * Route53
    * DynamoDB
    * Lambda
    * API
    * CloudWatch
* [Terraform](https://www.terraform.io/)
* [GitHub Actions](https://github.com/features/actions)

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- Blog -->
## Blog
<!-- ### Certification
The first stage of the challenge was to get an AWS certification. I had received my AWS cloud practioner certification in March 2021 -->
  
### HTML, CSS, S3
I tried to keep the front end very simple as I have minimal experience. I found a one page resume template that fit the look I was going for. The front end was done in HTML, styled with CSS and deployed in an S3 bucket that was configured as a static website. 
   
### DNS, CloudFront, ACM
I purchased a domain from Route53 and set the domain name to route traffic to the cloudfront distribution. Cloudfront offers 3 options of latency control based on cost. I used price class 100 as this will keep latency low for Europe, North America and Isreal and lower my costs. I enabled HTTPS by securing an SSL certificate from Aws Certificate Manager(ACM).

### DynamoDB, Lambda, API, CloudWatch, JavaScript
Deciding how to build the backend was the first challenge. I decided to start with the database and test the connection between each subsequent component before building the one after. Once the database and Lambda were set up I used the AWS console's built in test feature to check if I could update and display the count. 
Then I set up the API and integerated the lambda functions. Looking for ways to test the API led me to Postman, I kept getting errors with no logs. Connecting CloudWatch to the API gave me logs that allowed me to troubleshoot the errors. 
I finished up by adding JavaScript to the front end to display and increment the visitor counter. This failed until I enabled CORS.

### Infrastructure As Code, CI/CD, Testing, Locked TF State
I knew I wanted to use terraform from the beginning of the project so I wrote all the resources in one monolithic main.tf. This caused me huge issues when it came to refactoring my code into modules. In my attempts to fix the issues I listened to a stackoverflow comment whose solution was to delete the terraform state file. The resulting headache taught me to store the tf state file safely in an S3 bucket which supports locking.
After searching online for ways to include unit tests I came across Moto. It made it easy to mock DynamoDB so that I could test updating and displaying the database.
The last stages of the challenge was to include a CI/CD pipeline. I also included a manual approval stage.

![CI/CD Screenshot](./CICDscreenshot.png?raw=true "CI/CD Screenshot")
   
<p align="right">(<a href="#top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap

- [] Integration test

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Souher Hassan - souher.hassan0@gmail.com

Project Link: [https://github.com/Souher/Cloud-resume-challenge](https://github.com/Souher/Cloud-resume-challenge)

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [For the amazing readme template](https://github.com/othneildrew/Best-README-Template/blob/master/README.md)

<p align="right">(<a href="#top">back to top</a>)</p>