package com.walmart.move.nim.ndof.picking.core.mappers;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.walmart.move.nim.fes.common.domain.dtos.FulfillmentMetaData;
import com.walmart.move.nim.fes.common.domain.dtos.planner.FulfillmentDto;
import com.walmart.move.nim.fes.common.enums.FacilityType;
import com.walmart.move.nim.fes.common.enums.OrderRecType;
import com.walmart.move.nim.fes.common.utils.MDCUtils;
import com.walmart.move.nim.fes.dao.entity.FulfillmentEntity;
import com.walmart.move.nim.fulfillment.commons.Fulfillment;
import com.walmart.move.nim.fulfillment.commons.FulfillmentStatus;
import com.walmart.move.nim.fulfillment.commons.FulfillmentSystem;
import com.walmart.move.nim.fulfillment.commons.InBoundChannelMethod;
import com.walmart.move.nim.fulfillment.commons.OutBoundChannelMethod;
import com.walmart.move.nim.fulfillment.commons.PrimeSlotTag;
import com.walmart.move.nim.glscommonutil.common.GlsCommonUtil;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.EnumUtils;

import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
<<<<<<< HEAD
        =======
import java.util.stream.Collectors;

>>>>>>> origin/us-wm-fc/development
import static com.walmart.move.nim.glscommonutil.common.GLSConstant.DEFAULT_USER_ID;
import static com.walmart.move.nim.glscommonutil.common.GlsCommonUtil.getDateTime;
import static com.walmart.move.nim.glscommonutil.context.filter.HeaderContextStore.*;
import static java.util.Optional.ofNullable;

public class FulfillmentEntityMapper {

    public static FulfillmentEntity mapFulfillmentDtoToFulfillmentEntity(FulfillmentDto fulfillment){
        FulfillmentEntity entity = new FulfillmentEntity();
        mapFulfillmentDtoToFulfillmentEntity(fulfillment, entity);
        return entity;
    }

<<<<<<< HEAD

    public static void mapFulfillmentDtoToFulfillmentEntity(FulfillmentDto fulfillment, FulfillmentEntity entity){
=======
        public static List<FulfillmentEntity> mapFulfillmentDtosToFulfillmentEntities(List<FulfillmentDto> fulfillments, Integer facilityNum, String facilityCountryCode){
            return fulfillments.stream().map(fulfillment -> mapFulfillmentDtoToFulfillmentEntity(fulfillment, facilityNum, facilityCountryCode)).collect(Collectors.toList());
        }

        public static FulfillmentEntity mapFulfillmentDtoToFulfillmentEntity(FulfillmentDto fulfillment, Integer facilityNum, String facilityCountryCode){
>>>>>>> origin/us-wm-fc/development
            {
                List<String> cubbyTypes = ofNullable(fulfillment.getCubbyTypes()).orElse(Arrays.asList(""));
                FulfillmentMetaData fulfillmentMetaData= new FulfillmentMetaData();
                fulfillmentMetaData.setCubbyTypes(cubbyTypes);
                fulfillmentMetaData.setOrigFulfillmentUnitCount(fulfillment.getFulfillmentUnitCount());
<<<<<<< HEAD
                fulfillmentMetaData.setSourceLocationAddress(fulfillment.getSourceLocationAddress());
                fulfillmentMetaData.setDestinationLocationAddress(fulfillment.getDestinationLocationAddress());
                fulfillmentMetaData.setTrackingIdVersion(fulfillment.getTrackingIdVersion());

                entity.setFulfillmentId(fulfillment.getFulfillmentId());
                entity.setOrderChannelId(fulfillment.getOrderChannelId());
                entity.setLpn(fulfillment.getLpn());
                entity.setFulfillmentTypeCode(fulfillment.getFulfillmentType());
                entity.setFulfillmentStatusCode(ofNullable(fulfillment.getFulfillmentStatus()).orElse(FulfillmentStatus.CREATED));
                entity.setPrimeSlotTag(PrimeSlotTag.getByName(fulfillment.getPickSlotTag()));
                entity.setContainerTrackingId(fulfillment.getSrcCtnrTrckgId());
                entity.setOrgUnitId(fulfillment.getOrgUnitId());
                entity.setInboundChannelMethod(
                        ofNullable(fulfillment.getInboundChannelMethod()).map(channel -> InBoundChannelMethod.valueOf(channel))
                                .orElse(null));
                entity.setOutboundChannelMethod(ofNullable(fulfillment.getOutboundChannelMethod())
                        .map(channel -> OutBoundChannelMethod.valueOf(channel))
                        .orElse(null));
                entity.setFacilityNum(getTenantContext().getFacilityNumber());
                entity.setFacilityCountryCode(getTenantContext().getFacilityCountryCode());
                entity.setCreateTs(ofNullable(fulfillment.getCreateTs()).map(ts -> new Timestamp(ts.getTime()))
                        .orElse(getDateTime()));
                entity.setCreateUserId(ofNullable(fulfillment.getCreateUserid()).orElse(DEFAULT_USER_ID));
                entity.setLastChangeTs(ofNullable(fulfillment.getLastChangeTs()).map(ts -> new Timestamp(ts.getTime()))
                        .orElse(getDateTime()));
                entity.setLastChangeUserId(ofNullable(fulfillment.getLastChangeUserid()).orElse(DEFAULT_USER_ID));
                entity.setReleaseRequestId(ofNullable(fulfillment.getReleaseNbr()).map(Integer::valueOf)
                        .orElse(null));
                entity.setFulfillmentUnitCount(fulfillment.getFulfillmentUnitCount());
                entity.setDispatchTs(ofNullable(fulfillment.getDispatchTime()).map(ts -> new Timestamp(ts.getTime()))
                        .orElse(getDateTime()));
                entity.setMetaData(GlsCommonUtil.jsonToString(fulfillmentMetaData));
                entity.setFulfillmentSystem(EnumUtils.getEnumIgnoreCase(FulfillmentSystem.class, fulfillment.getFulfillmentSystem()));
                entity.setOrderRecType(ofNullable(fulfillment.getOrderRecType()).map(OrderRecType::getCode).orElse(0));
=======
                fulfillmentMetaData.setShippingTo(fulfillment.getShippingTo());
                return FulfillmentEntity.builder()
                        .fulfillmentId(fulfillment.getFulfillmentId())
                        .orderChannelId(fulfillment.getOrderChannelId())
                        .fulfillmentTypeCode(fulfillment.getFulfillmentType())
                        .fulfillmentStatusCode(ofNullable(fulfillment.getFulfillmentStatus()).orElse(FulfillmentStatus.CREATED))
                        .primeSlotTag(EnumUtils.getEnumIgnoreCase(PrimeSlotTag.class, fulfillment.getPickSlotTag()))
                        .containerTrackingId(fulfillment.getSrcCtnrTrckgId())
                        .orgUnitId(fulfillment.getOrgUnitId())
                        .inboundChannelMethod(
                                ofNullable(fulfillment.getInboundChannelMethod()).map(channel -> InBoundChannelMethod.valueOf(channel))
                                        .orElse(null))
                        .outboundChannelMethod(ofNullable(fulfillment.getOutboundChannelMethod())
                                .map(channel -> OutBoundChannelMethod.valueOf(channel))
                                .orElse(null))
                        .facilityNum(facilityNum)
                        .facilityCountryCode(facilityCountryCode)
                        .createTs(ofNullable(fulfillment.getCreateTs()).map(ts -> new Timestamp(ts.getTime()))
                                .orElse(getDateTime()))
                        .createUserId(ofNullable(fulfillment.getCreateUserid()).orElse(DEFAULT_USER_ID))
                        .lastChangeTs(ofNullable(fulfillment.getLastChangeTs()).map(ts -> new Timestamp(ts.getTime()))
                                .orElse(getDateTime()))
                        .lastChangeUserId(ofNullable(fulfillment.getLastChangeUserid()).orElse(DEFAULT_USER_ID))
                        .releaseRequestId(ofNullable(fulfillment.getReleaseNbr()).map(Integer::valueOf)
                                .orElse(null))
                        .fulfillmentUnitCount(fulfillment.getFulfillmentUnitCount())
                        .dispatchTs(ofNullable(fulfillment.getDispatchTime()).map(ts -> new Timestamp(ts.getTime()))
                                .orElse(getDateTime()))
                        .metaData(GlsCommonUtil.jsonToString(fulfillmentMetaData))
                        .fulfillmentSystem(EnumUtils.getEnumIgnoreCase(FulfillmentSystem.class, fulfillment.getFulfillmentSystem()))
                        .orderRecType(ofNullable(fulfillment.getOrderRecType()).map(OrderRecType::getCode).orElse(0))
                        .build();
>>>>>>> origin/us-wm-fc/development
            }
        }

        public static FulfillmentEntity mapFulfillmentToFulfillmentEntity(Fulfillment fulfillment, FacilityType facilityType) {
            return FulfillmentEntity.builder()
                    .fulfillmentId(fulfillment.getFulfillmentId())
                    .fulfillmentTypeCode(fulfillment.getFulfillmentType())
                    .fulfillmentStatusCode(ofNullable(fulfillment.getFulfillmentStatus()).orElse(FulfillmentStatus.CREATED))
                    .primeSlotTag(ofNullable(fulfillment.getPrimeSlotTag()).orElse(null))
                    .containerTrackingId(FacilityType.GDC.equals(facilityType)?fulfillment.getCtnrTrckgId():fulfillment.getSrcCtnrTrckgId())
                    .orgUnitId(fulfillment.getOrgUnitId())
                    .loadId(ofNullable(fulfillment.getLoadId()).map((loadId -> Integer.parseInt(loadId))).orElse(null))
                    .loadDate(GlsCommonUtil.convertToTimeStamp(fulfillment.getRouteDate()))
                    .inboundChannelMethod(
                            ofNullable(fulfillment.getInboundChannelMethod()).map(channel -> InBoundChannelMethod.valueOf(channel))
                                    .orElse(null))
                    .outboundChannelMethod(ofNullable(fulfillment.getOutboundChannelMethod())
                            .map(channel -> OutBoundChannelMethod.valueOf(channel))
                            .orElse(null))
                    .facilityNum(MDCUtils.getFacilityNumber())
                    .facilityCountryCode(MDCUtils.getFacilityCountryCode())
                    .createTs(ofNullable(fulfillment.getCreateTs()).map(ts -> new Timestamp(ts.getTime()))
                            .orElse(getDateTime()))
                    .createUserId(ofNullable(fulfillment.getCreateUserid()).orElse(DEFAULT_USER_ID))
                    .lastChangeTs(ofNullable(fulfillment.getLastChangeTs()).map(ts -> new Timestamp(ts.getTime()))
                            .orElse(getDateTime()))
                    .lastChangeUserId(ofNullable(fulfillment.getLastChangeUserid()).orElse(DEFAULT_USER_ID))
                    .releaseRequestId(ofNullable(fulfillment.getReleaseNbr()).map(Integer::valueOf)
                            .orElse(null))
                    .fulfillmentUnitCount(fulfillment.getFulfillmentUnitCount())
                    .dispatchTs(
                            ofNullable(fulfillment.getDispatchTs())
                                    .map(ts -> new Timestamp(ts.getTime()))
                                    .orElse(getDateTime())
                    )
                    .fulfillmentSystem(fulfillment.getFulfillmentSystem())
                    .shipmentSeqNbr(fulfillment.getStopSeqNbr())
                    .deliveryTs(
                            ofNullable(fulfillment.getDeliveryTs())
                                    .map(ts -> new Timestamp(ts.getTime()))
                                    .orElse(getDateTime())
                    )
                    .loadDate(ofNullable(fulfillment.getRouteDate()).map(date->Timestamp.from(date.toInstant())).orElse(null))
                    .whseAreaGroup(CollectionUtils.isNotEmpty(fulfillment.getWarehouseAreaGroupCode()) ? fulfillment.getWarehouseAreaGroupCode().get(0) : null)
                    .shiftNbr(fulfillment.getShiftNbr())
                    .levelNbr(fulfillment.getLevelNbr())
                    .pickDate(ofNullable(fulfillment.getRouteDate()).map(date->Timestamp.from(date.toInstant())).orElse(null))
                    .fulfillmentDate(fulfillment.getFulfillmentDate())
                    .tripId(fulfillment.getTripUUID())
                    .shortFulfillmentId(fulfillment.getShortFulfillmentId())
                    .destBUNbr(fulfillment.getDestBUNumber())
                    .isPlanningCompleted(Boolean.FALSE)
                    .palletGroupId(fulfillment.getPalletGroupId())
                    .sourceSystem(fulfillment.getSourceSystem())
                    .baseDivName(fulfillment.getBaseDivName())
                    .isRevPalletBuild(Objects.nonNull(fulfillment.getPalletGroupDetails())?fulfillment.getPalletGroupDetails().getReversePalletBuild():null)
                    .isSinglePalletBuild(Objects.nonNull(fulfillment.getPalletGroupDetails())?fulfillment.getPalletGroupDetails().getSinglePalletTripGroup():null)
                    .tripCategory(Objects.nonNull(fulfillment.getPalletGroupDetails())?fulfillment.getPalletGroupDetails().getTripCategory():null)
                    .build();
        }

        public static FulfillmentDto mapFulfillmentEntityToFulfillmentDto(FulfillmentEntity fulfillment) {
            return FulfillmentDto.builder()
                    .fulfillmentId(fulfillment.getFulfillmentId())
                    .fulfillmentType(fulfillment.getFulfillmentTypeCode())
                    .fulfillmentSystem(Objects.nonNull(fulfillment.getFulfillmentSystem()) ? fulfillment.getFulfillmentSystem().name() : null)
                    .build();
        }
    }
