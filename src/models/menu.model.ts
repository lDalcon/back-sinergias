export class Menu {
    role: string = '';
    opciones: MenuItem[] = []
    
    constructor(){}    
}

class MenuItem {
    label?: string;
    icon?: string;
    url?: string;
    items?: MenuItem[];
    badge?: string;
    routerLink?: any;
}