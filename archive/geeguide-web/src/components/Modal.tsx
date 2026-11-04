import {useEffect,useRef,type ReactNode} from 'react';import {Icon} from './Icon';
export function Modal({title,onClose,children,wide=false}:{title:string;onClose:()=>void;children:ReactNode;wide?:boolean}){
 const ref=useRef<HTMLDialogElement>(null);
 useEffect(()=>{const old=document.activeElement as HTMLElement;const previous=document.body.style.overflow;ref.current?.showModal();document.body.style.overflow='hidden';return()=>{document.body.style.overflow=previous;old?.focus();};},[]);
 return <dialog ref={ref} className={`modal ${wide?'wide':''}`} aria-labelledby="dialog-title" onCancel={e=>{e.preventDefault();onClose();}} onClick={e=>{if(e.target===e.currentTarget)onClose();}}><div className="modal-head"><h2 id="dialog-title">{title}</h2><button className="icon-button" aria-label="Close dialog" onClick={onClose}><Icon name="close"/></button></div>{children}</dialog>;
}
