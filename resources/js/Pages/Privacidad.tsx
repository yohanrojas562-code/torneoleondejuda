import { PageProps } from '@/types';
import { Head, Link } from '@inertiajs/react';
import { ArrowLeft, ShieldCheck, Mail } from 'lucide-react';
import MobileSideDrawer from '@/Components/MobileSideDrawer';

type Props = PageProps<{
    settings: Record<string, string | null>;
    lastUpdated: string;
}>;

const H2 = ({ children }: { children: React.ReactNode }) => (
    <h2 className="text-xl sm:text-2xl font-bold text-brand-gold mt-8 mb-3">{children}</h2>
);
const H3 = ({ children }: { children: React.ReactNode }) => (
    <h3 className="text-base sm:text-lg font-semibold text-white mt-5 mb-2">{children}</h3>
);
const P = ({ children }: { children: React.ReactNode }) => (
    <p className="text-gray-300 leading-relaxed mb-4 text-sm sm:text-base">{children}</p>
);
const UL = ({ children }: { children: React.ReactNode }) => (
    <ul className="list-disc list-outside ml-5 text-gray-300 space-y-1 mb-4 text-sm sm:text-base">{children}</ul>
);

export default function Privacidad({ settings = {}, lastUpdated }: Props) {
    const siteName = settings.site_name || 'Torneo León de Judá';
    const logoUrl = settings.logo ? `/storage/${settings.logo}` : null;
    const contactEmail = 'admin@torneoleondejuda.com';

    return (
        <>
            <Head>
                <title>{`Política de Privacidad - ${siteName}`}</title>
                <meta
                    name="description"
                    content={`Política de privacidad del ${siteName}: qué datos recolectamos, cómo los usamos y cómo proteger tu información.`}
                />
            </Head>

            <div className="bg-brand-black min-h-screen flex flex-col">
                <header className="bg-brand-black/95 backdrop-blur-sm border-b border-brand-gold/20">
                    <div className="max-w-5xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between">
                        <Link href="/" className="flex items-center gap-3">
                            {logoUrl
                                ? <img src={logoUrl} alt={siteName} className="h-10 w-10 object-contain" />
                                : <span className="text-brand-gold font-bold text-xl">LJ</span>
                            }
                            <span className="text-white font-bold text-base hidden sm:block">{siteName}</span>
                        </Link>
                        <Link href="/" className="hidden sm:flex text-gray-300 hover:text-brand-gold transition items-center gap-1.5 text-sm">
                            <ArrowLeft className="w-4 h-4" />
                            <span>Volver al inicio</span>
                        </Link>
                        <MobileSideDrawer />
                    </div>
                </header>

                <main className="flex-1">
                    <section className="py-10 px-4">
                        <div className="max-w-3xl mx-auto">
                            <div className="text-center mb-10">
                                <div className="inline-flex items-center justify-center w-14 h-14 rounded-full bg-brand-gold/10 mb-4">
                                    <ShieldCheck className="w-7 h-7 text-brand-gold" />
                                </div>
                                <span className="text-brand-gold text-sm font-semibold uppercase tracking-wider">Legal</span>
                                <h1 className="text-3xl sm:text-4xl font-extrabold text-white mt-2 tracking-tight">
                                    Política de Privacidad
                                </h1>
                                <p className="text-gray-400 mt-3 text-sm">
                                    Última actualización: {lastUpdated}
                                </p>
                            </div>

                            <div className="text-gray-300">
                                <P>
                                    El <strong className="text-white">{siteName}</strong> ("nosotros", "el torneo") respeta tu privacidad
                                    y se compromete a proteger los datos personales que recolectamos a través de
                                    nuestra plataforma web (
                                    <a href="https://torneoleondejuda.com" className="text-brand-gold hover:underline">torneoleondejuda.com</a>
                                    ) y nuestra aplicación móvil oficial para Android.
                                </P>
                                <P>
                                    Esta política describe qué información recolectamos, cómo la usamos, con quién
                                    la compartimos y qué derechos tienes sobre tus datos.
                                </P>

                                <H2>1. Quiénes somos</H2>
                                <P>
                                    El {siteName} es un torneo de fútbol de salón organizado por una iglesia
                                    cristiana en Medellín, Antioquia, Colombia. El responsable del tratamiento de
                                    los datos es el comité organizador del torneo.
                                </P>

                                <H2>2. Qué datos recolectamos</H2>
                                <H3>Datos de cuenta</H3>
                                <UL>
                                    <li>Nombre completo</li>
                                    <li>Correo electrónico</li>
                                    <li>Contraseña (almacenada cifrada con hash)</li>
                                    <li>Rol dentro del torneo (administrador, líder de equipo, capitán, árbitro)</li>
                                </UL>

                                <H3>Datos de jugadores inscritos</H3>
                                <UL>
                                    <li>Nombres y apellidos</li>
                                    <li>Fecha de nacimiento</li>
                                    <li>Número de identificación (cédula o documento)</li>
                                    <li>Número de camiseta y posición</li>
                                    <li>Equipo y temporada en la que participa</li>
                                    <li>Foto del jugador y copia digital del documento de identidad
                                        (subidos por el líder del equipo)</li>
                                </UL>

                                <H3>Datos generados durante el torneo</H3>
                                <UL>
                                    <li>Goles, asistencias, tarjetas amarillas y rojas</li>
                                    <li>Estadísticas de partidos y posiciones</li>
                                    <li>Solicitudes PQRS (peticiones, quejas, reclamos, sugerencias)</li>
                                </UL>

                                <H3>Permisos en la aplicación móvil</H3>
                                <UL>
                                    <li><strong className="text-white">Cámara:</strong> para escanear códigos QR de verificación de jugadores
                                        y para capturar fotos de jugadores al inscribirlos.</li>
                                    <li><strong className="text-white">Almacenamiento / Archivos:</strong> para seleccionar imágenes y
                                        documentos al subir información de jugadores.</li>
                                    <li><strong className="text-white">Internet:</strong> para comunicarse con nuestro servidor.</li>
                                </UL>
                                <P>
                                    Solo solicitamos estos permisos cuando son necesarios para usar la función
                                    específica, y puedes denegarlos sin afectar el resto de la app.
                                </P>

                                <H2>3. Cómo usamos tus datos</H2>
                                <UL>
                                    <li>Gestionar la inscripción de jugadores y equipos en cada temporada.</li>
                                    <li>Calcular la tabla de posiciones, goleadores y valla menos vencida.</li>
                                    <li>Generar carnés de jugadores con código QR para verificación en cancha.</li>
                                    <li>Procesar PQRS y mantener comunicación con líderes y capitanes.</li>
                                    <li>Mejorar la plataforma y proteger contra fraude o abuso.</li>
                                </UL>

                                <H2>4. Con quién compartimos tus datos</H2>
                                <P>
                                    <strong className="text-white">No vendemos ni cedemos tus datos personales a terceros.</strong>
                                </P>
                                <P>
                                    Cierta información de participación deportiva es pública por la naturaleza del
                                    torneo: nombres de jugadores, números de camiseta, equipo, goles anotados y
                                    tarjetas son visibles en la página pública del torneo y en la app. Esto
                                    aplica únicamente a jugadores inscritos oficialmente, no a datos sensibles
                                    como documento de identidad o fecha exacta de nacimiento.
                                </P>
                                <P>
                                    Datos sensibles (documentos de identidad, contraseñas, correos) son visibles
                                    únicamente para administradores autorizados del comité organizador.
                                </P>

                                <H2>5. Dónde se almacenan los datos</H2>
                                <P>
                                    Todos los datos se almacenan en servidores ubicados en Colombia, bajo nuestra
                                    administración directa. Usamos cifrado en tránsito (HTTPS/TLS) y
                                    contraseñas hashadas. Los tokens de sesión de la aplicación móvil se guardan
                                    en almacenamiento seguro del dispositivo (Android Keystore / EncryptedSharedPreferences).
                                </P>

                                <H2>6. Tiempo de retención</H2>
                                <P>
                                    Conservamos los datos de jugadores y resultados de torneos de forma indefinida
                                    como registro histórico del torneo. Los datos de cuenta (correo, contraseña)
                                    se conservan mientras la cuenta esté activa. Si solicitas la eliminación de
                                    tu cuenta, anonimizamos tu información personal pero podemos conservar
                                    estadísticas deportivas agregadas sin asociarlas a tu identidad.
                                </P>

                                <H2>7. Tus derechos</H2>
                                <P>
                                    De acuerdo con la Ley 1581 de 2012 (Habeas Data, Colombia) tienes derecho a:
                                </P>
                                <UL>
                                    <li>Conocer, actualizar y rectificar tus datos personales.</li>
                                    <li>Solicitar copia de la información que tenemos sobre ti.</li>
                                    <li>Revocar la autorización y/o solicitar la supresión de tu cuenta.</li>
                                    <li>Ser informado sobre el uso que se ha dado a tus datos.</li>
                                    <li>Presentar quejas ante la Superintendencia de Industria y Comercio.</li>
                                </UL>
                                <P>
                                    Para ejercer cualquiera de estos derechos, escríbenos a{' '}
                                    <a href={`mailto:${contactEmail}`} className="text-brand-gold hover:underline">{contactEmail}</a>
                                    {' '}o radica una PQRS desde la sección correspondiente del sitio web o la app móvil.
                                </P>

                                <H2>8. Menores de edad</H2>
                                <P>
                                    Algunos jugadores inscritos pueden ser menores de edad. La inscripción de
                                    menores es realizada por el líder de equipo o representante legal con
                                    autorización del padre, madre o tutor. No recolectamos datos directamente
                                    de menores; los datos se entregan a través de su representante.
                                </P>

                                <H2>9. Cookies y tecnologías similares</H2>
                                <P>
                                    El sitio web usa cookies de sesión (Laravel session) para mantener tu inicio
                                    de sesión. No usamos cookies de seguimiento publicitario, ni servicios de
                                    analítica de terceros que perfilen al usuario.
                                </P>

                                <H2>10. Servicios de terceros</H2>
                                <P>
                                    La aplicación móvil se distribuye a través de Google Play. Google puede
                                    recolectar datos de uso técnico (instalaciones, errores, idioma del
                                    dispositivo) sujetos a la{' '}
                                    <a href="https://policies.google.com/privacy" target="_blank" rel="noopener noreferrer" className="text-brand-gold hover:underline">
                                        Política de Privacidad de Google
                                    </a>.
                                </P>

                                <H2>11. Cambios a esta política</H2>
                                <P>
                                    Podemos actualizar esta política cuando agreguemos nuevas funcionalidades o
                                    cambien las leyes aplicables. La fecha de "Última actualización" al inicio
                                    de este documento siempre reflejará la versión vigente. Cambios sustanciales
                                    serán notificados por correo electrónico a los usuarios registrados.
                                </P>

                                <H2>12. Contacto</H2>
                                <P>
                                    Para cualquier pregunta o solicitud relacionada con esta política o con el
                                    tratamiento de tus datos personales, contáctanos a través de:
                                </P>
                                <div className="bg-brand-gold/5 border border-brand-gold/30 rounded-lg p-4 mt-3 flex items-center gap-3">
                                    <Mail className="w-5 h-5 text-brand-gold flex-shrink-0" />
                                    <a
                                        href={`mailto:${contactEmail}`}
                                        className="text-brand-gold hover:underline font-medium"
                                    >
                                        {contactEmail}
                                    </a>
                                </div>
                            </div>

                            <div className="mt-10 text-center">
                                <Link
                                    href="/"
                                    className="inline-flex items-center gap-2 text-brand-gold hover:text-brand-gold-light transition text-sm"
                                >
                                    <ArrowLeft className="w-4 h-4" />
                                    Volver al inicio
                                </Link>
                            </div>
                        </div>
                    </section>
                </main>
            </div>
        </>
    );
}
