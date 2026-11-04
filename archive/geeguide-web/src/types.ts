export type Service = {id:string;title:string;subtitle:string;category:string;icon:string;color:string;location:string;description:string;sourceId:string;actionLabel:string;actionUrl:string;note:string;keywords:string[];goals:string[];steps:string[]};
export type Catalog = {checkedAt:string;sources:{id:string;title:string;url:string}[];services:Service[]};
export type View = 'discover'|'explore'|'plan'|'passport'|'privacy'|'design';
export type Plan = {saved:string[];done:string[]};
