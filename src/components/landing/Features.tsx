import { Brain, BookHeart, Sparkles } from "lucide-react";
import { Card } from "@/components/ui/card";
import trackingImage from "@/assets/feature-tracking.jpg";
import aiImage from "@/assets/feature-ai.jpg";
import journalImage from "@/assets/feature-journal.jpg";

const features = [
  {
    icon: Sparkles,
    title: "Rastreamento Inteligente",
    description: "Acompanhe seu ciclo com precisão e receba previsões personalizadas para cada fase",
    image: trackingImage,
    benefits: ["Calendário intuitivo", "Previsões precisas", "Alertas personalizados"]
  },
  {
    icon: Brain,
    title: "Luna Sense - Assistente IA",
    description: "Converse 24/7 com sua assistente de bem-estar que realmente te entende",
    image: aiImage,
    benefits: ["Disponível 24/7", "Respostas empáticas", "Adapta-se ao seu ciclo"]
  },
  {
    icon: BookHeart,
    title: "Diário com IA",
    description: "Escreva sobre seu dia e receba insights poderosos sobre padrões e emoções",
    image: journalImage,
    benefits: ["Análise automática", "Identifica padrões", "Sugestões práticas"]
  }
];

export const Features = () => {
  return (
    <section className="py-24 bg-background">
      <div className="container mx-auto px-4">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <h2 className="text-4xl md:text-5xl font-bold mb-6">
            Ferramentas que transformam seu{" "}
            <span className="gradient-text">bem-estar</span>
          </h2>
          <p className="text-xl text-muted-foreground">
            Tecnologia de ponta combinada com empatia e privacidade para apoiar cada dimensão da sua saúde
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8 max-w-7xl mx-auto">
          {features.map((feature, index) => {
            const Icon = feature.icon;
            return (
              <Card 
                key={index}
                className="group hover:shadow-xl transition-all duration-300 overflow-hidden border-2 hover:border-primary/20 bg-card"
              >
                <div className="aspect-square overflow-hidden">
                  <img 
                    src={feature.image} 
                    alt={feature.title}
                    className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                  />
                </div>
                <div className="p-6 space-y-4">
                  <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center">
                    <Icon className="w-6 h-6 text-primary" />
                  </div>
                  <h3 className="text-2xl font-bold">{feature.title}</h3>
                  <p className="text-muted-foreground">{feature.description}</p>
                  <ul className="space-y-2">
                    {feature.benefits.map((benefit, idx) => (
                      <li key={idx} className="flex items-center gap-2 text-sm">
                        <div className="w-1.5 h-1.5 rounded-full bg-primary" />
                        <span>{benefit}</span>
                      </li>
                    ))}
                  </ul>
                </div>
              </Card>
            );
          })}
        </div>
      </div>
    </section>
  );
};
