import { LightningElement, api, track } from 'lwc';
import CAROUSEL_IMAGES from '@salesforce/resourceUrl/miskiMayoGetToKnowUsCustomThirdCarouselWrapper';
import styleMiskiMayoGetToKnowUsCustomThirdCarouselWrapper from '@salesforce/resourceUrl/styleMiskiMayoGetToKnowUsCustomThirdCarouselWrapper';
import { loadStyle } from 'lightning/platformResourceLoader';

export default class MiskiMayoGetToKnowUsCustomThirdCarouselWrapper extends LightningElement {
    @track currentStartIndex = 0;
    stylesLoaded = false;

    slidesData = [
        { image: CAROUSEL_IMAGES + '/photo1.jpg', description: 'En marzo, ProInversión adjudicó el proyecto Bayóvar a Miski Mayo, subsidiaria de Vale Rio Dolce. El 05 de mayo se realiza la firma del contrato.' },
        { image: CAROUSEL_IMAGES + '/photo2.jpg', description: 'Se realizan los primeros trabajos de exploración en la concesión Bayóvar 2 con la autorización del MINEM.' },
        { image: CAROUSEL_IMAGES + '/photo3.jpg', description: 'Se capacita a sechuranos como operadores de maquinaria pesada y operadores de procesos de Puerto y Planta, de igual manera a proveedores locales.' },
        { image: CAROUSEL_IMAGES + '/photo4.jpg', description: 'Se coloca la primera piedra con la participación del Expresidente de la República, Alan García.' },
        { image: CAROUSEL_IMAGES + '/photo5.jpg', description: 'Comienza la construcción de la infraestructura de Mina, Planta Concentradora y Puerto.' },
        { image: CAROUSEL_IMAGES + '/photo6.jpg', description: 'El 10 de julio se inician nuestras operaciones oficialmente. Los socios fueron Vale (40%), Mosaic (35%) y Mitsui (25%).' },
        { image: CAROUSEL_IMAGES + '/photo7.jpg', description: 'Se desarrolla el proyecto de Forestación sembrando 35 mil plantones de algarrobos y zapotes en 350 hectáreas en Illescas, desierto de Sechura.' },
        { image: CAROUSEL_IMAGES + '/photo8.jpg', description: 'En setiembre, obtenemos la certificación ISO 9001 en el Servicio de Embarque de Concentrado de fosfato de nuestro terminal Portuario.' },
        { image: CAROUSEL_IMAGES + '/photo9.jpg', description: 'El 8 de enero, Mosaic Company se convierte en el accionista mayoritario de Miski Mayo con el 75% de acciones; Mitsui mantiene el otro 25%.' },
        { image: CAROUSEL_IMAGES + '/photo10.jpg', description: 'En octubre, alineados a nuestra corporación Mosaic, implementamos el proceso de Transformación para promover la excelencia corporativa.' },
        { image: CAROUSEL_IMAGES + '/photo11.jpg', description: 'En julio cumplimos nuestros primeros 10 años de operación, enfrentando la pandemia del Covid-19.' },
        { image: CAROUSEL_IMAGES + '/photo12.jpg', description: 'Alineados a nuestra corporación, iniciamos oficialmente nuestra política y programa de Diversidad e Inclusión.' },
        { image: CAROUSEL_IMAGES + '/photo13.jpg', description: 'En agosto, incorporamos 4 buses eléctricos, siendo la primera minera peruana con una flota de buses 100% eléctricos para transporte de personal.' },
        { image: CAROUSEL_IMAGES + '/photo14.jpg', description: 'Marilza Carneloz es nombrada Directora - Presidenta de Miski Mayo, siendo una de las primeras mujeres en liderar una empresa minera en el Perú.' },
        { image: CAROUSEL_IMAGES + '/photo15.jpg', description: 'Obtuvimos la Huella de Carbono Perú Nivel 1, por calcular nuestras emisiones de Gases de Efecto Invernadero (GEI) del período 2023, otorgado por el MINAM.' }
    ];

    // get visibleSlides() {
    //     return this.slidesData.slice(this.currentStartIndex, this.currentStartIndex + 4);
    // }

    get slidesToShow() {
        if (window.innerWidth <= 480) {
            return 1;
        } else if (window.innerWidth <= 1024) {
            return 2;
        } else {
            return 4;
        }
    }
    
    get visibleSlides() {
        return this.slidesData.slice(this.currentStartIndex, this.currentStartIndex + this.slidesToShow);
    }
    

    get trackStyle() {
        return 'display: flex;';
    }

    // renderedCallback() {
    //     if (!this.stylesLoaded) {
    //         Promise.all([loadStyle(this, styleMiskiMayoGetToKnowUsCustomThirdCarouselWrapper)])
    //             .then(() => {
    //                 console.log("Custom styles loaded");
    //                 this.stylesLoaded = true;
    //             })
    //             .catch((error) => {
    //                 console.error("Error loading custom styles");
    //             });
    //     }
    // }

    renderedCallback() {
        if (!this.stylesLoaded) {
            Promise.all([loadStyle(this, styleMiskiMayoGetToKnowUsCustomThirdCarouselWrapper)])
                .then(() => {
                    console.log("Custom styles loaded");
                    this.stylesLoaded = true;
                })
                .catch((error) => {
                    console.error("Error loading custom styles");
                });
        }
    
        window.addEventListener('resize', () => {
            this.currentStartIndex = 0; // Resetar quando redimensionar
            this.requestUpdate && this.requestUpdate(); // forçar update se necessário
        });
    }

    // previousSlide() {
        // if (this.currentStartIndex > 0) {
        //     this.currentStartIndex--;
        //     return;
        // }

        // if(this.currentStartIndex == 0)
        // {
        //     this.currentStartIndex = 12;
        // }
    // }

    // nextSlide() {
        
    //     if(this.currentStartIndex == 12)
    //         {
    //             this.currentStartIndex = 0;
    //             return;
    //         }

    //     if (this.currentStartIndex <= this.slidesData.length - 4) {
    //         this.currentStartIndex++;
    //         return;
    //     }

    //     if(this.currentStartIndex == 11)
    //     {
    //         this.currentStartIndex = 12;
    //         return;
    //     }
    // }

    previousSlide() {

        if(this.slidesToShow == 4)
        {
            if (this.currentStartIndex > 0) {
                this.currentStartIndex--;
                return;
            }
    
            if(this.currentStartIndex == 0)
            {
                this.currentStartIndex = 12;
            }
            
        } else
        {
            if (this.currentStartIndex > 0) {
                this.currentStartIndex--;
            } else {
                this.currentStartIndex = this.slidesData.length - this.slidesToShow;
            }

        }
        //here
        // if (this.currentStartIndex > 0) {
        //     this.currentStartIndex--;
        // } else {
        //     this.currentStartIndex = this.slidesData.length - this.slidesToShow;
        // }
    }
    
    nextSlide() {
        let maxIndex = this.slidesData.length - this.slidesToShow;
        if(this.slidesToShow == 4)
        {
            maxIndex++;
        }
        if (this.currentStartIndex < maxIndex) {
            this.currentStartIndex++;
        } else {
            this.currentStartIndex = 0;
        }
    }
    
}