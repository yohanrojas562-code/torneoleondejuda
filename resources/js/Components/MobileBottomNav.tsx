import { Link, usePage } from '@inertiajs/react';
import { Home, Calendar, Trophy, Target } from 'lucide-react';

const items = [
    { href: '/', label: 'Inicio', icon: Home },
    { href: '/calendario', label: 'Calendario', icon: Calendar },
    { href: '/tabla-de-posiciones', label: 'Posiciones', icon: Trophy },
    { href: '/goleadores', label: 'Goleadores', icon: Target },
];

export default function MobileBottomNav() {
    const { url } = usePage();
    const currentPath = url.split('?')[0];

    const isActive = (href: string) => {
        if (href === '/') return currentPath === '/';
        return currentPath === href || currentPath.startsWith(href + '/');
    };

    return (
        <>
            <div className="md:hidden h-20" aria-hidden="true" />
            <nav className="md:hidden fixed bottom-0 left-0 right-0 z-50 bg-brand-black/95 backdrop-blur-md border-t border-brand-gold/20 shadow-[0_-4px_20px_rgba(0,0,0,0.5)]">
                <div className="grid grid-cols-4 max-w-md mx-auto">
                    {items.map(({ href, label, icon: Icon }) => {
                        const active = isActive(href);
                        return (
                            <Link
                                key={href}
                                href={href}
                                className={`relative flex flex-col items-center justify-center py-2.5 gap-1 transition-colors ${
                                    active ? 'text-brand-gold' : 'text-gray-500 hover:text-gray-300'
                                }`}
                            >
                                {active && (
                                    <span className="absolute top-0 left-1/2 -translate-x-1/2 w-10 h-0.5 bg-brand-gold rounded-b-full" />
                                )}
                                <Icon className="w-5 h-5" strokeWidth={active ? 2.5 : 2} />
                                <span className={`text-[10px] ${active ? 'font-bold' : 'font-medium'}`}>{label}</span>
                            </Link>
                        );
                    })}
                </div>
            </nav>
        </>
    );
}
