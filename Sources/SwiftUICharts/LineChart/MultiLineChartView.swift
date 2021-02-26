//
//  File.swift
//  
//
//  Created by Samu András on 2020. 02. 19..
//

import SwiftUI

public struct MultiLineChartView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var data:[MultiLineChartData]
    public var title: String
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var formSize: CGSize
    public var dropShadow: Bool
    public var valueSpecifier:String
    
    @State private var touchLocation:CGPoint = .zero
    @State private var showIndicatorDot: Bool = false
    @State private var currentValue: Double = 2 {
        didSet{
            if (oldValue != self.currentValue && showIndicatorDot) {
                HapticFeedback.playSelection()
            }
            
        }
    }
    
    var globalMin:Double {
        if let min = data.flatMap({$0.onlyPoints()}).min() {
            return min
        }
        return 0
    }
    
    var globalMax:Double {
        if let max = data.flatMap({$0.onlyPoints()}).max() {
            return max
        }
        return 0
    }
    
    var frame = CGSize(width: 180, height: 120)
    private var rateValue: Int?
    
    public init(data: [([Double], GradientColor)],
                title: String,
                legend: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                form: CGSize = ChartForm.medium,
                rateValue: Int? = nil,
                dropShadow: Bool = true,
                valueSpecifier: String = "%.1f") {
        
        self.data = data.map({ MultiLineChartData(points: $0.0, gradient: $0.1)})
        self.title = title
        self.legend = legend
        self.style = style
        self.darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.lineViewDarkMode
        self.formSize = form
        frame = CGSize(width: self.formSize.width, height: self.formSize.height/2)
        self.rateValue = rateValue
        self.dropShadow = dropShadow
        self.valueSpecifier = valueSpecifier
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            Spacer()
            GeometryReader{ geometry in
                ZStack{
                    ForEach(0..<self.data.count) { i in
                        Line(data: self.data[i],
                             frame: .constant(geometry.frame(in: .local)),
                             touchLocation: self.$touchLocation,
                             showIndicator: self.$showIndicatorDot,
                             minDataValue: .constant(self.globalMin),
                             maxDataValue: .constant(self.globalMax),
                             showBackground: false,
                             gradient: self.data[i].getGradient(),
                             index: i)
                    }
                }
            }
            .frame(width: frame.width, height: frame.height + 30)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .offset(x: 0, y: 0)
        }
        .frame(width: self.formSize.width, height: self.formSize.height)
        .gesture(DragGesture()
                    .onChanged({ value in
                    })
                    .onEnded({ value in
                        self.showIndicatorDot = false
                    })
        )
    }
}

struct MultiWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MultiLineChartView(data: [([8,23,54,32,12,37,7,23,43], GradientColors.orange),([9,11,40,28,19,30,4,35,27], GradientColors.bluPurpl)], title: "Line chart", legend: "Basic")
                .environment(\.colorScheme, .light)
        }
    }
}
