class Cerveza {
	const property lupulo
	const property pais
	const property precio
	method graduacion() 
}

class Rubia inherits Cerveza {
	var property graduacion
}

class Negra inherits Cerveza {
    override method graduacion() = graduacionReglamentaria.graduacion().min(2 * lupulo)	
}

class Roja inherits Negra {
	override method graduacion() = super() * 1.25
}

object graduacionReglamentaria {
	var property graduacion = 0.04
}

class Jarra {
	const property capacidadL
	const property marca
	const property carpa
	method contenidoDeAlcohol() = capacidadL * marca.graduacion()
}

class Persona {
	var property peso
	const property jarrasCompradas = []
	var property musicaTradicional
	var property nivelDeAguante
	const property nacionalidad
	method comprarJarra(cerveza){
		jarrasCompradas.add(cerveza)
	}
	method totalDeAlcohol() = jarrasCompradas.sum({c => c.contenidoDeAlcohol()})
	method estaEbria() =  self.totalDeAlcohol() * peso > nivelDeAguante
	method leGusta(cerveza) 
	method quiereEntrar(carpa) = self.leGusta(carpa.vendeMarca()) and carpa.tieneBanda() == musicaTradicional
	 method jarrasConMasDe1Litro() {
    	return jarrasCompradas.all({
    		c => c.capacidadL() >= 1
    	})
    }
    
    method esPatriota() {
    	return jarrasCompradas.all({
    		c => c.marca().pais() == nacionalidad
    	})
    }
    
    method marcaDeJarrasCompradas() {
    	return jarrasCompradas.map({
    		c => c.marca()
    	}).asSet()
    }
    
    method esCompatibleCon(persona) {
    	if (self.lasJarrasDeUno(persona) == 0 or self.lasJarrasDeOtro(persona) == 0) {
    		return false
    	} else {
    		return (self.lasJarrasDeUno(persona) / self.lasJarrasDeOtro(persona)) <= 2
    	}
  	}
    
    method lasJarrasDeUno(persona) {
    	return self.marcaDeJarrasCompradas().size()
    }
    
    method lasJarrasDeOtro(persona) {
    	return self.marcaDeJarrasCompradas().intersection(persona.marcaDeJarrasCompradas()).size()
    }
    
    method carpasDondeSeTomo() {
    	return jarrasCompradas.map({
    		c => c.carpa()
    	}).asSet()
    }
    
    method listaDelitrosTomados() {
    	return jarrasCompradas.map({c => c.capacidadJarra()})
    } 
    
    method estaEnVicio() {
		if (self.listaDelitrosTomados().size() == 0 or self.listaDelitrosTomados().size() == 1) {
			return false
		} else {
			return self.listaDelitrosTomados().get(self.listaDelitrosTomados().size() - 2) <= self.listaDelitrosTomados().last() 
		}
	}
	
	method gastoTotalCerveza() {
		return jarrasCompradas.sum({
			c => c.precio()
		})
	}
	
	method jarraMasCara() {
		return jarrasCompradas.max({
			c => c.precio()
		})
	}
}

class Belga inherits Persona {
	override method leGusta(cerveza) = cerveza.lupulo() > 0.04
}

class Checos inherits Persona {
	override method leGusta(cerveza) = cerveza.graduacion() > 0.08
}

class Aleman inherits Persona {
	override method leGusta(cerveza) = true
}

class Carpa {
	const property limite
	var property tieneBanda
	const property vendeMarca
    var property personasDentro = []
    var property recargo
    
    method limiteMaxDeCarpa() {
        return limite == 40
    }
    method ingresar(persona) {
    	personasDentro.add(persona)
    }
    
    method carpaEsPar() {
    	return personasDentro.size().even()
    }
    
    method dejaIngresar(persona) {
    	return limite > personasDentro.size() and not persona.estaEbria()
    }
    
    method servirCerveza(persona, litros) {
    	if (personasDentro.contains(persona)) {
    		persona.comprarJarra(new Jarra(capacidadL= litros, marca = vendeMarca, carpa = self))
    	} else {
    		self.error("La persona no está en la carpa")
    	}
    }
    
    method ebriosEmpedernidos() {
    	return personasDentro.count({
    		p => p.estaEbria() and p.jarrasConMasDe1Litro()
    	})
    }
    
    method esHomogenea() {
    	return personasDentro.map({
    		p => p.nacionalidad()
    	}).asSet().size() == 1
    }
    
    method clientesSinServir() {
    	return personasDentro.filter({
    		p => not p.carpasDondeSeTomo().contains(self)
    	})
    }  
}

object recargoFijo {
	
   	method recargo(carpa) = 1.30
}

object recargoPorCantidad {
	
	method recargo(carpa) {
		if(carpa.capacidadDeCarpa() == 0 or carpa.personasDentro().size() == 0) {
			return 1
		} else if (carpa.capacidadDeCarpa() / carpa.personasDentro().size() <= 2) {
			return 1.40
		} else {
			return 1.25
		}
	}
} 

object recargoPorEbriedad {
	
	method recargo(carpa) {
		const personasEbrias = carpa.personasDentro().count({p => p.estaEbria()})
		
		if (personasEbrias == 0 or carpa.personasDentro().size() == 0) {
			return 1
		} else if (personasEbrias >= carpa.personasDentro().size() * 0.75) {
			return 1.50
		} else {
			return 1.20
		}
	}
	
} 