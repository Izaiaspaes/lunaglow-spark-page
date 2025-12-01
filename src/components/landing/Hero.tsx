import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ArrowRight, Sparkles, Shield, Heart } from "lucide-react";
import heroImage from "@/assets/hero-woman.jpg";

export const Hero = () => {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden bg-gradient-to-br from-background via-luna-pink-light to-luna-peach">
      {/* Decorative elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-20 right-20 w-72 h-72 bg-luna-pink/10 rounded-full blur-3xl animate-pulse" />
        <div className="absolute bottom-32 left-20 w-96 h-96 bg-luna-purple/10 rounded-full blur-3xl animate-pulse delay-700" />
      </div>

      <div className="container mx-auto px-4 py-20 relative z-10">
        <div className="grid lg:grid-cols-2 gap-12 items-center max-w-7xl mx-auto">
          {/* Left Content */}
          <div className="space-y-8 text-center lg:text-left">
            <Badge className="bg-secondary text-primary border-0 px-4 py-2 text-sm font-medium">
              <Sparkles className="w-4 h-4 mr-2" />
              Oferta Especial - 70% OFF no Plano Anual
            </Badge>

            <div className="space-y-4">
              <h1 className="text-5xl md:text-6xl lg:text-7xl font-bold leading-tight">
                Seu ciclo, sua{" "}
                <span className="gradient-text">força</span>
              </h1>
              <p className="text-xl md:text-2xl text-foreground/80 max-w-2xl mx-auto lg:mx-0">
                Entenda seu corpo, antecipe suas fases e receba planos personalizados por IA para cada momento do seu ciclo
              </p>
            </div>

            <div className="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start">
              <Button 
                size="xl" 
                variant="cta" 
                className="group"
                onClick={() => window.location.href = 'https://lunaglow.com.br/auth'}
              >
                Comece Grátis Agora
                <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
              </Button>
              <Button 
                size="xl" 
                variant="ctaOutline"
              >
                Ver Planos Premium
              </Button>
            </div>

            {/* Trust indicators */}
            <div className="flex flex-wrap gap-8 justify-center lg:justify-start pt-8">
              <div className="flex items-center gap-2 text-sm">
                <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                  <Shield className="w-5 h-5 text-primary" />
                </div>
                <div className="text-left">
                  <div className="font-semibold">100% Privado</div>
                  <div className="text-muted-foreground text-xs">Seus dados seguros</div>
                </div>
              </div>
              <div className="flex items-center gap-2 text-sm">
                <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                  <Heart className="w-5 h-5 text-primary" />
                </div>
                <div className="text-left">
                  <div className="font-semibold">500+ Mulheres</div>
                  <div className="text-muted-foreground text-xs">Já transformaram</div>
                </div>
              </div>
            </div>
          </div>

          {/* Right Image */}
          <div className="relative">
            <div className="relative rounded-3xl overflow-hidden shadow-2xl">
              <img 
                src={heroImage} 
                alt="Mulher feliz usando o Luna Glow" 
                className="w-full h-auto object-cover"
              />
            </div>
            {/* Floating card */}
            <div className="absolute -bottom-6 -left-6 bg-white/95 backdrop-blur-sm rounded-2xl p-6 shadow-xl border border-border max-w-xs">
              <div className="text-sm text-muted-foreground mb-1">Última análise</div>
              <div className="text-lg font-semibold mb-2">Seu sono melhorou 23%</div>
              <div className="flex items-center gap-2">
                <div className="flex-1 h-2 bg-secondary rounded-full overflow-hidden">
                  <div className="h-full w-[75%] gradient-bg rounded-full" />
                </div>
                <span className="text-xs font-medium text-primary">75%</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};
