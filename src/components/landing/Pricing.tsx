import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Check, Crown, Sparkles } from "lucide-react";

const plans = [
  {
    name: "Gratuito",
    price: "R$ 0",
    period: "para sempre",
    description: "Perfeito para começar sua jornada",
    features: [
      "Rastreamento básico do ciclo",
      "Calendário menstrual",
      "Previsões de fase",
      "Acesso limitado ao Luna Sense",
    ],
    cta: "Começar Grátis",
    variant: "ctaOutline" as const,
    popular: false
  },
  {
    name: "Premium Mensal",
    price: "R$ 29,90",
    period: "/mês",
    description: "Todas as funcionalidades desbloqueadas",
    features: [
      "Tudo do plano Gratuito",
      "Luna Sense 24/7 ilimitado",
      "Diário com análise IA completa",
      "Planos personalizados para cada fase",
      "Insights de saúde avançados",
      "Suporte prioritário",
    ],
    cta: "Assinar Agora",
    variant: "cta" as const,
    popular: true
  },
  {
    name: "Premium Anual",
    price: "R$ 179,90",
    originalPrice: "R$ 358,80",
    period: "/ano",
    badge: "70% OFF",
    description: "Melhor custo-benefício",
    features: [
      "Tudo do Premium Mensal",
      "Economia de R$ 178,90",
      "2 meses grátis",
      "Acesso vitalício a novos recursos",
      "Comunidade exclusiva",
      "Conteúdo premium mensal",
    ],
    cta: "Aproveitar Oferta",
    variant: "cta" as const,
    popular: false,
    highlight: true
  }
];

export const Pricing = () => {
  return (
    <section className="py-24 bg-gradient-to-b from-background to-luna-pink-light/30">
      <div className="container mx-auto px-4">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <Badge className="bg-primary/10 text-primary border-0 mb-4">
            <Sparkles className="w-4 h-4 mr-2" />
            Oferta Limitada
          </Badge>
          <h2 className="text-4xl md:text-5xl font-bold mb-6">
            Escolha o plano perfeito para você
          </h2>
          <p className="text-xl text-muted-foreground">
            Comece grátis e faça upgrade quando estiver pronta para transformar seu bem-estar
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8 max-w-7xl mx-auto">
          {plans.map((plan, index) => (
            <Card 
              key={index}
              className={`relative p-8 space-y-6 transition-all duration-300 ${
                plan.highlight 
                  ? 'border-4 border-primary shadow-2xl scale-105 bg-gradient-to-br from-white to-luna-pink-light' 
                  : 'border-2 hover:border-primary/30 hover:shadow-xl'
              }`}
            >
              {plan.popular && (
                <Badge className="absolute -top-3 left-1/2 -translate-x-1/2 bg-primary text-white">
                  Mais Popular
                </Badge>
              )}
              
              {plan.badge && (
                <Badge className="absolute -top-3 right-6 gradient-bg text-white font-bold px-4 py-1">
                  {plan.badge}
                </Badge>
              )}

              <div className="space-y-2">
                <h3 className="text-2xl font-bold flex items-center gap-2">
                  {plan.name}
                  {plan.highlight && <Crown className="w-5 h-5 text-primary" />}
                </h3>
                <p className="text-sm text-muted-foreground">{plan.description}</p>
              </div>

              <div className="space-y-1">
                <div className="flex items-baseline gap-2">
                  <span className="text-5xl font-bold">{plan.price}</span>
                  <span className="text-muted-foreground">{plan.period}</span>
                </div>
                {plan.originalPrice && (
                  <div className="text-sm text-muted-foreground line-through">
                    De {plan.originalPrice}
                  </div>
                )}
              </div>

              <Button 
                size="lg" 
                variant={plan.variant}
                className="w-full"
                onClick={() => window.location.href = 'https://lunaglow.com.br/auth'}
              >
                {plan.cta}
              </Button>

              <ul className="space-y-3 pt-4">
                {plan.features.map((feature, idx) => (
                  <li key={idx} className="flex items-start gap-3">
                    <div className="w-5 h-5 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0 mt-0.5">
                      <Check className="w-3 h-3 text-primary" />
                    </div>
                    <span className="text-sm">{feature}</span>
                  </li>
                ))}
              </ul>
            </Card>
          ))}
        </div>

        <div className="text-center mt-12 text-sm text-muted-foreground">
          Todos os planos incluem 7 dias de garantia de satisfação • Cancele quando quiser
        </div>
      </div>
    </section>
  );
};
