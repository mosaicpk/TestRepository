import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getKnowledgeArticles from '@salesforce/apex/PMC_SS_HomePageController.getKnowledgeArticles';
import getAllKnowledgeArticles from '@salesforce/apex/PMC_SS_HomePageController.getAllKnowledgeArticles';

export default class Pmc_ss_testparentcomponent extends LightningElement {

    slider1Image = 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80';
    slider1Link = '#';
    slider2Image = 'https://store-images.s-microsoft.com/image/apps.32256.14224494707314076.8116b5ee-01ee-49e4-827c-bc6739343224.90a3690d-d956-4e1a-a673-1871117b442a?mode=scale&q=90&h=720&w=1280';
    slider2Link = '#';
    slider3Image = 'https://www.virginexperiencedays.co.uk/content/img/product/large/the-view-from-the-12102928.jpg';
    slider3Link = '#';
    slider4Image = 'https://t-ec.bstatic.com/images/hotel/max1024x768/169/169160530.jpg';
    slider4Link = '#';
    autoScroll = true;

    @track knowledgeArticles = [];
    @track allKnowledgeArticles = [];
    
    connectedCallback() {
        console.log('Result connectedCallback');
        //this.fetchKnowledgeArticles();
        this.fetchAllKnowledgeArticles();
        }

    fetchKnowledgeArticles() {
        getKnowledgeArticles().then(result => {
            if(result != undefined) {
                this.knowledgeArticles = result;
            }
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                  title: "Error in fetching data",
                  message: error.body.message,
                  variant: "error",
                }),
              );
        });
    }

    fetchAllKnowledgeArticles() {
        getAllKnowledgeArticles().then(result => {
            console.log('result ',result);
            if(result != undefined) {
                for(var i=0; i<result.length; i++) {
                    console.log('wrapper.publishStatus');
                    if(result[i].publishStatus == 'Online') {
                        console.log('resultb push ');
                        
                        this.knowledgeArticles.push(result[i]);
                    }else{
                        console.log('else part '+result[i].publishStatus );
                    }
                }
                console.log('allKnowledge');
                this.allKnowledgeArticles = result;
                console.log('allKnowledgeArticles ',this.allKnowledgeArticles);
    
            }
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                  title: "Error in fetching data",
                  message: error.body.message,
                  variant: "error",
                }),
              );
        });
    }

    get sliderData() {
        try{
        var array = [];
        console.log('this.knowledgeArticles ',this.knowledgeArticles);
        for(var i=0; i<this.knowledgeArticles.length; i++) {
            console.log('i '+ i);
            array.push({
                "image": this.knowledgeArticles[i].imageUrl,
                "link": this.slider1Link,
                "heading": this.knowledgeArticles[i].title,
                "description": this.knowledgeArticles[i].description
            });
        }
        }catch(error){
            console.log('Error',error);
        }
        console.log('array ',array);
        return array;
    }
}