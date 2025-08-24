import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { PoModule } from "@po-ui/ng-components";
import { PoTemplatesModule } from "@po-ui/ng-templates";
import { AppComponent } from './app.component';
import { AboutComponent } from './components/about/about.component';
import { ViewComponent } from './components/view/view.component';

@NgModule({
  declarations: [
    AppComponent,
    AboutComponent,
    ViewComponent,
    
  ],
  imports: [
    BrowserModule,
    PoModule,
    PoTemplatesModule
    
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
