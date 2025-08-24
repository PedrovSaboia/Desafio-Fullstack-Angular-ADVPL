import { CommonModule } from '@angular/common';
import { HttpClientModule } from '@angular/common/http';
import { Component } from '@angular/core';
import { Router, RouterOutlet } from '@angular/router';
import { ProtheusLibCoreModule } from '@totvs/protheus-lib-core';

import {
  PoMenuItem,
  PoMenuModule,
  PoPageModule,
  PoToolbarModule,
  PoButtonModule,
} from '@po-ui/ng-components';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    CommonModule,
    RouterOutlet,
    PoToolbarModule,
    ProtheusLibCoreModule,
    PoMenuModule,
    PoPageModule,
    HttpClientModule,
    PoButtonModule,
  ],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent {


   //As opções do menu esquerto
  readonly menus: Array<PoMenuItem> = [

    { label: 'Ajuda (Help)', action: this.aboutClick.bind(this), icon: 'po-icon-help', shortLabel: 'Ajuda' },
    { label: 'Sair', action: this.closeApp.bind(this), icon: 'po-icon-exit', shortLabel: 'Sair' }
  ];
  router: any;
  proAppConfigService: any;

  //Sobre
  private aboutClick() {
    this.router.navigate(['/', 'about']);
  }

  //Sair
  private closeApp() {
    alert("Clique não veio do Protheus");
  }


  private onClick() {
    alert('Clicked in menu item');
  }
}


