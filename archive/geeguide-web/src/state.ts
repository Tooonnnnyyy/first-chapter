import type {Plan,Service} from './types';
export const storageKey='geeguide.plan.v1';
export function cleanPlan(raw:unknown,services:Service[]):Plan {
 const value=raw as Partial<Plan>|null;const ids=new Set(services.map(s=>s.id));const steps=new Set(services.flatMap(s=>s.steps.map((_,i)=>`${s.id}:${i}`)));
 const saved=Array.isArray(value?.saved)?[...new Set(value.saved.filter(x=>typeof x==='string'&&ids.has(x)))]:[];
 return {saved,done:Array.isArray(value?.done)?[...new Set(value.done.filter(x=>typeof x==='string'&&steps.has(x)&&saved.includes(x.split(':')[0])))]:[]};
}
export function readPlan(services:Service[]):Plan {try{return cleanPlan(JSON.parse(localStorage.getItem(storageKey)||'null'),services);}catch{return {saved:[],done:[]};}}
export const goals=[{id:'essay',title:'Ace an assignment',description:'Sources, research & citations',icon:'quote'},{id:'study',title:'Find a place to focus',description:'Study rooms & accessible spaces',icon:'armchair'},{id:'create',title:'Make something new',description:'Podcasts, video & digital tools',icon:'mic'},{id:'technology',title:'Find the right tools',description:'Equipment, software & support',icon:'laptop'},{id:'first',title:'Find my feet',description:'A friendly first visit',icon:'compass'},{id:'group',title:'Work with my group',description:'Space to meet & create',icon:'users'}];
